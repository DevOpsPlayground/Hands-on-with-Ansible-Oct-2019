# Structure of a playbook with roles

```bash
├── ansible.cfg             # configuration
├── group_vars              #
│   └── lamp.yml            # variables
├── inventory               # inventory of hosts
|
├── roles                   #
│   ├── common              # common role
│   │   └── tasks           #
│   │       └── main.yml    # installing basic tasks
|
│   ├── db                  # db role
|   │   ├── handlers        #
│   │   │   └── main.yml    # start db and restart apache2
│   │   └── tasks           #
│   │   |   ├── harden.yml  # security hardening for mysql
│   │   |   └── main.yml    # install mysql and include harden.yml
│   │   └── vars            #
│   │       └── main.yml    # variables for db role
|
│   ├── php                 # php role
│   │   └── tasks           #
│   │       └── main.yml    # install php and restart apache2
|
│   └── webserver           # apache2 role
│   |   ├── handlers        #
│   |   │   └── main.yml    # start apache2
│   |   ├── tasks           #
│   |   │   └── main.yml    # install apache
│   |   ├── templates       #
│   |   │   └── web.conf.j2 # apache2 custom configuration
│   |   |   └── web.port.j2 # apache2 custom port
│   |   └── vars            #
│   |       └── main.yml    # variables for webserver role
|
|   └── wordpress           # wordpress role
│       ├── tasks           #
│       │   └── main.yml    # install and configure Wordpress
│       ├── templates       #
│       │   ├── create_wp_db.j2     # create and configure a wordpress db in mysql
│       │   └── wp.conf.j2  # configure mysql and php for wordpress
│       └── vars            #
│           └── main.yml    # Variables for wordpress role
|
└── site.yml                # master playbook (contains list of roles)
```

__*Back to [README](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/README.md)*__
