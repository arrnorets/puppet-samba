class samba::service( Boolean $samba_enabled ) {
    service { "smbd":
        ensure => $samba_enabled,
        enable => $samba_enabled,
        require => Class[ "samba::install" ]
    }

    service { "nmbd":
        ensure => $samba_enabled,
        enable => $samba_enabled,
        require => Class[ "samba::install" ]
    }
}
