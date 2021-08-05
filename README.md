# Table of contents
1. [Common purpose](#1-common-purpose)
2. [Compatibility](#2-compatibility)
3. [Installation](#3-installation)
4. [Config example in Hiera and result files](#4-config-example-in-hiera-and-result-files)


# 1. Common purpose
Samba is a module for samba service config and package version manasging.

# 2. Compatibility
This module was tested on CentOS 7 and Gentoo Linux. However, it should work on newer versions of CentOS, Fedora and RHEL as well where Ansible 2.9 or newer is available. 

# 3. Installation
```yaml
mod 'samba',
    :git => 'https://github.com/arrnorets/puppet-samba.git',
    :ref => 'main'
```

# 4. Config example in Hiera and result files
This module follows the concept of so called "XaaH in Puppet". The principles are described [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/puppet-modules-organization/) and [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/3-hashes-in-hiera/).

Here is the example of config in Hiera:
```yaml
---
samba:
  packages:
    ansible: '2.9.10-1.el7'
    samba: "present"

  enable: true

  users:
    "<user>": "<password>"

  config:
    global:
      workgroup: "MYGROUP"
      server string: "Samba Server on mypc"
      server role: "standalone server"
      hosts allow: "192.168.1. 127."
      log file: "/var/log/samba/log.%m"
      max log size: 50
      interfaces: "192.168.1.22/24"

    asg_work:
      path: "/home/<user>/work/syseng"
      "write list": "<user>"
      writable: "yes"
      printable: "no"
      create mask: "0644"
      directory mask: "0755"
```
It will install ansible and samba packages, enable services smbd and nmbd and produce the folowing files:
+ /etc/samba/smb.conf:
    ```bash
    [global]
    workgroup = MYGROUP
    server string = Samba Server on mypc
    server role = standalone server
    hosts allow = 192.168.1. 127.
    log file = /var/log/samba/log.%m
    max log size = 50
    interfaces = 192.168.1.22/24
      
    [asg_work]
    path = /home/<user>/work/syseng
    write list = <user>
    writable = yes
    printable = no
    create mask = 0644
    directory mask = 0755
    ```
+ /opt/ansible4puppet-samba/conf/site.yml:
    ```yaml
    - name: Configure SAMBA users
      hosts: localhost
      strategy: linear
      vars:
        users_to_add:
        - name: "<user>"
          passwd: "<password>"
    
        users_to_remove: [] 
    
    
      tasks:
      - name: Set samba users
        shell: |
                (echo '{{ item.passwd }}'; echo '{{ item.passwd }}') | smbpasswd -s -a "{{ item.name }}"
        with_items:
          - "{{ users_to_add }}"
        no_log: True
        delegate_to: localhost
    
      - name: Remove samba users
        shell: |
                smbpasswd -x "{{ item.name }}"
        with_items:
          - "{{ users_to_remove }}"
        no_log: True
        delegate_to: localhost
    ```

The Ansible site.yml will be executed by exec resource inside of the module once the file site.yml changes.
