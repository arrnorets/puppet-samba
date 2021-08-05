
module Puppet::Parser::Functions
  newfunction(:generate_Ansible_Config_For_Samba_Users, :type => :rvalue, :doc => <<-EOS
    Generates configuration for ansible task that configures SAMBA users.
    EOS
  ) do |arguments|
    users_from_hiera = arguments[0]
    current_users = arguments[1]
    
    users_to_add_list = "users_to_add:"
    users_to_add = ""
    users_from_hiera.each do | u, p |
      if current_users.include?("#{u}") == false
         users_to_add = users_to_add + "    - name: " + u + "\n"
         users_to_add = users_to_add + "      passwd: " + p + "\n"
      end
    end
    if users_to_add == ""
        users_to_add_list = users_to_add_list + " [] \n\n"
    else
       users_to_add_list = users_to_add_list + "\n" + users_to_add
    end

    users_to_remove_list = "    users_to_remove:"
    users_to_remove = ""
    current_users.each do | u |
      if users_from_hiera.has_key?("#{u}") == false
        users_to_remove = users_to_remove + "    - name: " + u + "\n"
      end
    end
    if users_to_remove == ""
      users_to_remove_list = users_to_remove_list + " [] \n\n"
    else
      users_to_remove_list = users_to_remove_list + "\n" + users_to_remove
    end

    return users_to_add_list.to_s + "\n" + users_to_remove_list.to_s
  end
end

