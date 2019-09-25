# Hierarchy structure

```bash
├── ansible.cfg             # configuration
├── inventory               # inventory of hosts
├── group_vars              #
│   └── lamp.yml            # variables
├── roles                   #
│   ├── common              # common role
│   │   └── tasks           #
│   │       └── main.yml    # installing basic tasks
│   ├── db                  # db role
|   │   ├── handlers        #
│   │   │   └── main.yml    # start db and restart apache2
│   │   └── tasks           #
│   │   |   ├── harden.yml  # install mysql and include harden.yml
│   │   |   └── main.yml    # security hardening for mysql
│   │   └── vars            #
│   │       └── main.yml    # variables for db role
│   ├── php                 #
│   │   └── tasks           # installing php and restart apache2
│   │       └── main.yml
│   └── web                 # apache2 role
│       ├── handlers        #
│       │   └── main.yml    # start apache2
│       ├── tasks           #
│       │   └── main.yml    # install apache
│       ├── templates       #
│       │   └── web.conf.j2 # apache2 custom configuration
│       └── vars            #
│           └── main.yml    # variables for web role
└── site.yml                # master playbook (contains list of roles)
```

__*Back to [README](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/README.md)*__
