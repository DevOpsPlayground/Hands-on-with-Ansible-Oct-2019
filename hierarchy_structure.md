    inventory               # inventory file
    group_vars/             #
    all.yml                 # variables
    site.yml                # master playbook (contains list of roles)
    roles/                  #
        common/             # common role
            tasks/          #
                main.yml    # installing basic tasks
        web/                # apache2 role
            tasks/          #
                main.yml    # install apache
            templates/      #
                web.conf.j2 # apache2 custom configuration
            vars/           # 
                main.yml    # variables for web role 
            handlers/       #
                main.yml    # start apache2
        php/                # php role
            tasks/          # 
                main.yml    # installing php and restart apache2
        db/                 # db role
            tasks/          #
                main.yml    # install mysql and include harden.yml
                harden.yml  # security hardening for mysql
            handlers/       #
                main.yml    # start db and restart apache2
            vars/           #
                main.yml    # variables for db role