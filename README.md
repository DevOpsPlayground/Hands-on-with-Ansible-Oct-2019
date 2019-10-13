# ANSIBLE HANDS-ON

## Our task: Create a real-world LAMP stack for development using Ansible

You will need:

1. The information-slip you picked up at reception.
2. Chrome (preferably but Firefox can also do).

------

### Ansible control node and remote hosts

Ansible works from a control machine to send commands to one or more remote machines.
In Ansible terminology, these are referred to as a *control node* and *remote hosts*.
We have set up a control node and one remote host for each one of you to use.

You may have noticed from your information-slip that you have been assigned  two animal names. These animals have been used to ensure everyone has unique host names.
So, for example, imagine Bob has a panda and a tiger :-) We have set up machines control_panda and remote_tiger for Bob to practice Ansible commands with.

Further these machines can be accessed via a command line in the browser (a web terminal called WeTTy), under the following links:

- <http://control_panda.ldn.devopsplayground.com/wetty/>
- <http://remote_tiger.ldn.devopsplayground.com/wetty/>

representing the Ansible control node and remote host, respectively.

### Let's start

1. Open up the <http://control_panda.ldn.devopsplayground.com/wetty/> (use animal name on you info-slip)

2. You will be prompted for a login password. Use the one on your information-slip.

3. Type some shell commands to get familiar with the web terminal.
   From now on we will be working from the browsers only.

4. As a convenience let's set some ENVIRONMENT variables that we will use later

```bash
export REMOTE_HOST=remote_host_ip       # e.g. export REMOTE_HOST=52.214.226.94
export PASSWORD=remote_host_password    # e.g. export PASSWORD=London
```

-----

## Step 1. Install Ansible

Check whether Ansible is installed by running:

```bash
ansible --version  
ansible 2.8.5       # you should see something like this
...
```

If not, run these commands:

```bash
sudo apt update     # [sudo] password for playground:   (type in your password)
sudo apt install python3-pip
pip3 --version
sudo pip3 install ansible
```

and again

```bash
ansible --version
```

That's it!

## Step 2. Configuring SSH Access to the remote host

Run the following command from your control_panda.

```bash
cd Hands-on-with-Ansible-Oct-2019
./setup.sh $REMOTE_HOST
```

## Step 3. Let's check out the connectivity with the host

Run the following. And, yes! That comma is right in its place! It tells ansible that there is only that one host in your inline inventory. 

```bash
ansible all -i "$REMOTE_HOST," -m ping
```

 Or check memory and disk space on your remote_panda:

```bash
ansible all -i "$REMOTE_HOST," -m shell -a 'free -m && df -h'
```

## Step 4. Ansible Hostfile and configuration file

Let's create a directory where we will organize all our files for the playbook. Then run the `inventory_and_config.sh` file to create the inventory of hosts and Ansible configuration file.

```bash
mkdir playbook
./inventory_and_config.sh $REMOTE_HOST
```

## Step 5. Write a simple playbook

We will put together a simple playbook to update our remote host.
Create a file `update.yml` and paste the following. Careful with the spaces - YAML is fussy!

HINT: You can copy the file you have cloned from the repo.

```YAML
---
- hosts: lamp
  remote_user: playground
  become: yes

  tasks:
    - name: Update all packages on a Debian/Ubuntu
      apt:
        update_cache: yes
        upgrade: dist
        force_apt_get: yes

    - name: Check disk space and memory
      shell: free -m && df -h
```

### Tip!

What if we don't have access to the documentation in the web? Ansible ships with the `ansible-doc` tool. We can access the documentation from the command line.

```bash
ansible-doc apt
```

## Step 6. Run the playbook

```bash
ansible-playbook  -i ./playbook/inventory update.yml -v
```

The `-v` gives us a more detailed output from Ansible, once the playbook is run. Ansible is rich with feedback data. Try running the same command but with `-vv` or even `-vvvv`.

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

## 9. Notes

Link to the [git repository](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019) with the README and the playbooks that will be used in this session.

## 10. References

Some materials were adopted from this cool book:

[Security Automation with Ansible 2: Leverage Ansible 2 to Automate Complex Security Tasks Like Application Security, Network Security, and Malware Analysis](https://g.co/kgs/xbJUnr)

## Thanks for participating!
