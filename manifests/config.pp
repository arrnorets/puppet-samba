class samba::config ( Hash $samba_config, Hash $samba_users_from_hiera ) {

    $samba_options = hash2ini( $samba_config, " = ", true )

    file { "/etc/samba/smb.conf":
        ensure => file,
        owner => root,
        group => root,
        mode => '0644',
        content => inline_template( "${samba_options}\n" ),
        require => Class[ "samba::install" ],
        notify => Service[ "smbd", "nmbd" ]
    }

    file { "/opt/ansible4puppet-samba":
        ensure => directory,
        owner => root,
        group => root,
        mode => '0700'
    }

    file { "/opt/ansible4puppet-samba/conf" :
        ensure => directory,
        owner => root,
        group => root,
        mode => '0700'
    }

    $samba_users_ansible_config = generate_Ansible_Config_For_Samba_Users( $samba_users_from_hiera, $current_samba_users )

    file { "/opt/ansible4puppet-samba/conf/site.yml":
        ensure => file,
        owner => root,
        group => root,
        mode  => '0600',
        content => template( "samba/site.yml.erb" ),
        notify => Exec[ "configure_samba_users_via_ansible" ]
    }

    exec { "configure_samba_users_via_ansible":
        cwd => "/opt/ansible4puppet-samba/conf",
        path => ['/usr/bin', '/usr/sbin', '/bin', '/sbin', '/usr/local/bin', '/usr/local/sbin' ],
        command => "ansible-playbook site.yml"
    }

}
