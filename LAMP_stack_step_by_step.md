# ANSIBLE HANDS-ON

## Our task: Create a real-world LAMP stack for development using Ansible

Prerequisites:

1. Control node - it can be your laptop or any Unix, MacOs, Linux machine with Ansible installed.
2. Remote host with Python 3 (2.7 is still ok) already installed .
3. SSH access to the remote host is configured
4. Inventory and ansible.cfg files have been created.
Refer to the README.md if you need help.

------

## Step 7. Build a LAMP stack

We will look at how to write a LAMP stack playbook using the features offered by Ansible. Here is the high-level hierarchy structure of the playbook that will trigger the installation of LAMP:

```YAML
- name: LAMP stack setup on Ubuntu 18.04
  hosts: lamp
  remote_user: "{{ remote_username }}"
  become: True
  roles:
    - common
    - web
    - db
    - php
```

Before we start, take a look at the directory structure of a fully fledged playbook. Click here:
[Playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook). This is what we are aiming for ;-)

Run the following:

```bash
cd playbook
../create_structure.sh
tree .    # You sould see the following:
.
├── ansible.cfg
├── group_vars
├── inventory
└── roles
    ├── common
    │   └── tasks
    ├── db
    │   ├── handlers
    │   ├── tasks
    │   └── vars
    ├── php
    │   └── tasks
    └── web
        ├── handler
        ├── tasks
        ├── templates
        └── vars
```

### Step 7.1 The Common Role

We will populate now these folders with the neccessary content.

```bash
cd roles
```

Create `main.yml`

```bash
vi common/tasks/main.yml
```

and paste in the following:

```YAML
- name: Update all packages on a Debian/Ubuntu
  apt:
    update_cache: yes
    upgrade: dist
    force_apt_get: yes
  
- name: install curl
  apt:
    name: curl
    state: present
    update_cache: yes
    force_apt_get: yes
```

#### Tip! Check your [playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook) is correct!

### Step 7.2 The Web Role

#### 7.2.1 Install, configure and start apache2

Next step in our LAMP configuration is the installation of the Apache2 server. In `web/tasks/` create the `main.yml`

#### Hint - we are in roles/

```bash
vi web/tasks/main.yml
```

The following code will tell our Ansible to install Apache2 and configure it. It'll also add Apache2 to the startup service.

```YAML
- name: install apache2 server
  apt:
    name: apache2
    state: present
    force_apt_get: yes
  tags: ["web"]

- name: set the apache2 port to 8080
  template:
    src: web.port.j2
    dest: /etc/apache2/ports.conf
    owner: root
    group: root
    mode: 0644
  tags: ["web"]

- name: update the apache2 server configuration
  template:
    src: web.conf.j2
    dest: /etc/apache2/sites-available/000-default.conf
    owner: root
    group: root
    mode: 0644
  tags: ["web"]

- name: enable apache2 on startup
  systemd:
    name: apache2
    enabled: yes
  notify:
    - start apache2
  tags: ["web"]

```

Did you spot the `notify` parameter at the end of the file? In Ansible we call this a `handler` a very cool feature that will trigger the process (start apache2) only if anything changes after the playbook has run. Time and resources saving!  
Ok, let's create the handler now.

#### 7.2.2 Handling apache2 start

In `web/handlers/` create `main.yaml`

#### Hint - we are in roles/

```bash
vi web/handlers/main.yaml
```

and paste there the following:

```YAML
- name: start apache2
  systemd:
    state: started
    name: apache2

- name: stop apache2
  systemd:
    state: stopped
    name: apache2

- name: restart apache2
  systemd:
    state: restarted
    name: apache2
    daemon_reload: yes
```

#### 7.2.3 Templating

We need to configure our Apache server. For this purpose we will use the `template` feature. Ansible templates leverage the powerful and widely adopted Jinja2 templating engine. Let's go ahead and create two templates in this location -> `web/templates`.

#### We are still in /roles ;-)

```bash
vi web/templates/web.port.j2
```

Paste

```XML

# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 8080

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
````

Then
```bash
vi web/templates/web.conf.j2
```

Paste: 

```XML

<VirtualHost *:8080>
    ServerAdmin {{server_admin_email}}
    DocumentRoot {{server_document_root}}
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

The second template will be fed by the variables contained in `web/vars/main.yml`:

```bash
vi web/vars/main.yml
```

Paste:

```YAML
server_admin_email: playground@localhost.local
server_document_root: /var/www/html
```

#### Tip! Check your [playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook) is correct!

### Step 7.3 The DB Role

Now that we have provided for the installation of the server, let's write similarly a database role.

#### 7.3.1 Install, configure and start `mySQL`

The tasks we specify here will install `mySQL` with assigned passwords when prompted.

#### No doubts! We are still in `roles/`

Create the following file: `db/tasks/main.yml`.

```bash
vi db/tasks/main.yml
```

Paste:

```YAML
- name: set mysql root password
  debconf:
    name: mysql-server
    question: mysql-server/root_password
    value: "{{ mysql_root_password }}"
    vtype: password
  tags: ['mysql']

- name: confirm mysql root password
  debconf:
    name: mysql-server
    question: mysql-server/root_password_again
    value: "{{ mysql_root_password }}"
    vtype: password
  tags: ['mysql']

- name: install mysql-python
  apt:
    name: ['python-mysqldb',
    'python-pymysql',
    'python3-pymysql',
    'python-apt',
    'python3-apt']
    state: present
    force_apt_get: yes
  tags: ['mysql']

- name: install mysqlserver
  apt:
    name:
      ['mysql-server', 'mysql-client']
    state: present
    force_apt_get: yes
  tags: ['mysql']
  
- include: harden.yml
```

Notice the `include` statement. We can include a file with a list of plays or tasks in other files.
The `include` statement, along with `roles` alow to break large playbooks into smaller ones.
This will let us use them in parent playbooks or even multiple times in the same playbook.

The `harden.yml` will perform a hardening on mySQL server configuration.

```bash
vi db/tasks/harden.yml
```

Paste inside:

```YAML
- name: deletes anonymous mysql user
  mysql_user:
    user: ""
    state: absent
    login_password: "{{ mysql_root_password }}"
    login_user: root

- name: secures the mysql root user
  mysql_user:
    user: root
    password: "{{ mysql_root_password }}"
    host: "{{ item }}"
    login_password: "{{mysql_root_password}}"
    login_user: root
  with_items:
   - 127.0.0.1
   - localhost
   - ::1
   - "{{ ansible_fqdn }}"

- name: removes the mysql test database
  mysql_db:
    db: test
    state: absent
    login_password: "{{ mysql_root_password }}"
    login_user: root

- name: enable mysql on startup
  systemd:
    name: mysql
    enabled: yes
  notify:
    - start mysql
```

Similarly to how the `web` role was written, the `db server` role also uses a handler and local variables.
Create a `db/handlers/main.yml` file.

#### You know the drill - we are still in roles/ !

```bash
vi db/handlers/main.yml
```

Here is the content:

```YAML
- name: start mysql
  systemd:
    state: started
    name: mysql

- name: stop mysql
  systemd:
    state: stopped
    name: mysql

- name: restart mysql
  systemd:
    state: restarted
    name: mysql
    daemon_reload: yes
```

And here is the file `db/vars/main.yml`, containing the password for the `db` role:

```bash
vi db/vars/main.yml
```

```YAML
mysql_root_password: P@nd@$$w0rd

```

#### Tip! Check your [playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook) is correct!

### Step 7.4 The PHP Role

We will install PHP and then restart the Apache2 server to configure it to work with PHP. Again note the `notify` handler at the end of the file.

This is a quick one - again under `roles/` create `php/tasks/main.yml` file.

```bash
vi php/tasks/main.yml
```

```YAML
- name: install php7
  apt:
    name:
      ['php7.2-mysql',
      'php7.2-curl',
      'php7.2-json',
      'php7.2-cgi',
      'php7.2',
      'libapache2-mod-php7.2'
      ]
    state: present
    force_apt_get: yes
  notify:
    - restart apache2
  tags: ["web"]
  
```

#### Tip! Check your [playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook) is correct!

### And now let's create and run our playbook

Do you remember the YAML that was showing high-level structure of a playbook? Let's create it.

```bash
cd .. && vi site.yml    # We are now back in playbook/
```

Paste:

```YAML
- name: LAMP stack setup on Ubuntu 18.04
  hosts: lamp
  remote_user: "{{ remote_username }}"
  become: True
  roles:
    - common
    - web
    - db
    - php
```

Let' set our remote user globally:

```bash
echo remote_username: "playground" > group_vars/lamp.yml
```

#### You may want to check last time the  [playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook#hierarchy-structure-of-playbook)

And now run the playbook!

```bash
ansible-playbook -i inventory site.yml
```

Success!

#### Go to http://your_remote_server.com

You should see the default Apache for Ubuntu page.

## 9. References

Some materials were adopted from this cool book:

[Security Automation with Ansible 2: Leverage Ansible 2 to Automate Complex Security Tasks Like Application Security, Network Security, and Malware Analysis](https://g.co/kgs/xbJUnr)

## Thanks for participating!
