class samba::install ( Hash $samba_pkg_hash ) {
    
    $samba_pkg_names_array = keys( $samba_pkg_hash )
    $samba_pkg_names_array.each | String $pkg_name | {
        package { "${pkg_name}":
	    ensure => $samba_pkg_hash[ "${pkg_name}" ],
        }
    }
}

