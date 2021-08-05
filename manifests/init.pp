class samba {
    
    #Get all information about samba settings from Hiera using "hash" merging strategy.
    $hash_from_hiera = lookup('samba', { merge => 'deep' } ) 
    
    class { "samba::install" :
        samba_pkg_hash => $hash_from_hiera[ 'packages' ]
    }
    
    class { "samba::config" :
        samba_config => $hash_from_hiera[ 'config' ],
        samba_users_from_hiera => $hash_from_hiera[ 'users' ]
    }
    
    class { "samba::service" :
        samba_enabled => $hash_from_hiera[ 'enable' ]
    }
}
