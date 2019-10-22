# ANSIBLE HANDS-ON

## Our task: Create a real-world LAMP stack for development and deploy Wordpress app using Ansible

You will need:

1. The information-slip you picked up at reception.
2. The Google Chrome browser (preferably, but Firefox can also do).

------

### Ansible control node and remote hosts

Ansible works from a control machine to send commands to one or more remote machines.
In Ansible terminology, these are referred to as a *control node* and *remote hosts*.
We have set up a `control node` and one `remote host` for each one of you to use.

You may have noticed from your information-slip that you have been assigned two animal names. These animals have been used to ensure everyone has unique host names.
So, for example, imagine Bob has a `panda` and a `tiger` :smiley: . We have set up machines control_panda and remote_tiger for Bob to practice Ansible commands with.

Further these machines can be accessed via a command line in the browser (a web terminal called WeTTy), under the following links:

- <http://control_panda.ldn.devopsplayground.com/wetty/>
- <http://remote_tiger.ldn.devopsplayground.com/wetty/>

representing the Ansible `control node` and `remote host`, respectively.

### Let's start

1. Open up the <http://control_panda.ldn.devopsplayground.com/wetty/> (use the `animal name` on your info-slip).

2. You will be prompted for a login password. Use the one on your information-slip.

3. Type some shell commands to get familiar with the web terminal.
   From now on we will be working from the browsers only.

4. Without changing machine, (you are in your `control_panda`), set some ENVIRONMENT variables that you will use later. Again, the necessary details are on your information-slip.

```bash
export REMOTE_HOST=remote_host_ip       # type the IP address of your "remote_animal" machine.
                                        # e.g. export REMOTE_HOST=52.214.226.94
export PASSWORD=remote_host_password    # e.g. export PASSWORD=mys3kr3t
```

-----

## Step 1. Install Ansible

Check whether Ansible is installed by running:

```bash
ansible --version  
ansible 2.8.6       # If Ansible is installed you will see something like this
...
```

If not, run these commands:

```bash
sudo apt update     #  (respond with your password at the `[sudo] password for playground:` prompt)
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

and again

```bash
ansible --version
```

That's it!

## Step 2. Configuring passwordless SSH Access to the remote hos

Run the following command from your `control_panda`.

```bash
cd Hands-on-with-Ansible-Oct-2019
./setup.sh $REMOTE_HOST
```

You should see output something like the following:

![Output1](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/images/Screenshot%202019-10-21%20at%2023.57.21.png)

Answer yes to this question, then the proces should continue something like the following:

![Outout2](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/images/Screenshot%202019-10-22%20at%2000.01.24.png)

## Step 3. Let's check out the connectivity with the host

Run the following to ping the remote host.

And, yes! That `comma` is right in its place! It tells ansible that there is only that one host in your inline inventory.

```bash
ansible all -i "$REMOTE_HOST," -m ping
```

 Or check its memory and disk space:

```bash
ansible all -i "$REMOTE_HOST," -m shell -a 'free -m && df -h'
```

What we did just now was to run ansible `ad-hoc commands` on our remote host. [Let's explore ad-hoc commands :nerd_face:](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html)

## Step 4. Ansible Hostfile and configuration file

Let's  create the inventory of hosts and Ansible configuration file at the root of our project. Run:

```bash
./inventory_and_config.sh $REMOTE_HOST
```

Let's take a look what those two files look like for us:

```bash
cat playbook/inventory
# you should see something like:
[lamp]
lampstack ansible_host=52.214.226.94 ansible_become_pass=my_pass
```

Ansible has a `default inventory` and a `default configuration file`. Let's explore them as examples :nerd_face:

```bash
less /etc/ansible/hosts
```

and

```bash
less /etc/ansible/ansible.cfg
```

## Step 5. Write a simple playbook

We will put together a simple playbook to update our remote host, and check its memory and disk space. The first time around we did this using ad-hoc commands but this time we will transform them into a playbook file. We can now store this in version control, we can let other systems check it out and run it as many times as we want.
Create a file `update.yml`

```bash
# in ~/Hands-on-with-Ansible-Oct-2019

vi update.yml
```

and paste the following. Careful with the spaces - YAML is fussy!

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

Explore the output in the command line :nerd_face:

It starts like this:
![ansible-doc apt output](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/images/Screenshot%202019-10-22%20at%2012.36.18.png)

## Step 6. Run the playbook

```bash
ansible-playbook -i playbook/inventory update.yml
```

### Success!!

You should see something similar:
![Result](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/images/Screenshot%202019-10-20%20at%2018.49.34.png)

## Step 7. Build a LAMP stack and deploy Wordpress

We will now look at how to write a LAMP stack playbook using the features offered by Ansible.

The directory, where all our playbook files will live, has already been created for you. Unsurprisingly it is called `playbook`. But you can name it according to what its purpose is. It will become a good mnemonic for you.

Here is the high-level hierarchy structure of the playbook:

```YAML
- name: LAMP stack setup and Wordpress installation on Ubuntu 18.04
  hosts: lamp
  remote_user: "{{ remote_username }}"
  become: yes
  
  roles:
    - role: common
    - role: webserver
    - role: db
    - role: php
    - role: wordpress
```

Before we start, take a look at the directory structure of a fully fledged playbook. Click here:
[Playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook). This is what we are aiming for ;-)

To save time, I have already created some roles for you. Go back to the Web Terminal of your `control node` and take a look at the `playbook/` directory. Get familiar with the contents. Anything missing in `playbook/roles` :nerd_face:?

### Step 7.1 The Webserver Role

We will now write a Role to install and configure the Apache2 server.

#### 7.1.1 Install, configure and start apache2

First thing first - we'll install Apache2. Create the folder structure for the tasks:

```bash
cd playbook/roles     # if you haven't already :-)
mkdir -p webserver/tasks && vi webserver/tasks/main.yml
```

The following code will tell our Ansible to install Apache2 and configure it. It'll also add Apache2 to the startup service.

```YAML
- name: install apache2 server
  apt:
    name: apache2
    state: present
    force_apt_get: yes

- name: set the apache2 port to 8080
  template:
    src: web.port.j2
    dest: /etc/apache2/ports.conf
    owner: root
    group: root
    mode: 0644

- name: update the apache2 server configuration
  template:
    src: web.conf.j2
    dest: /etc/apache2/sites-available/000-default.conf
    owner: root
    group: root
    mode: 0644

- name: enable apache2 on startup
  systemd:
    name: apache2
    enabled: yes
  notify:
    - start apache2
```

Let's discuss what this task file is doing.
Hint: Use the `ansible-doc` command to help you. Example: `ansible-doc systemd`.

Did you spot the `notify` parameter at the end of the file? What you see listed as a parameter of the notify is the name of a `handler`. [Let's explore handlers :nerd_face:](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#handlers-running-operations-on-change)

Something interesting is going on here. The `handlers` are just another set of tasks, for example, `start apache2`, that will trigger a process only if they get `notified`. They get `notified` only if anything changes after the playbook has run. Another interesting fact is that, regardless of how many tasks throughout the playbook `notify` that particular `handler`, the process of restarting apache2 will be triggered only once. Time and resources saving!

Ok, let's create the handlers now.

#### 7.1.2 Handling apache2 start

In `webserver/handlers/` create `main.yaml`

```bash
# ~/Hands-on-with-Ansible-Oct-2019/playbook/roles

mkdir -p webserver/handlers && vi webserver/handlers/main.yaml
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

##### What is  [Idempotence](https://en.wikipedia.org/wiki/Idempotence)? :nerd_face:

#### 7.1.3 Templating

We need to configure our Apache server. For this purpose we will use the `template` module.
[Let's explore templates :nerd_face:](https://docs.ansible.com/ansible/2.5/modules/template_module.html#template-templates-a-file-out-to-a-remote-server)

Ansible templates leverage the powerful and widely adopted Jinja2 templating language. Let's go ahead and create two templates in this location -> `webserver/templates`.

```bash
# ~/Hands-on-with-Ansible-Oct-2019/playbook/roles

mkdir -p webserver/templates/ && vi webserver/templates/web.port.j2
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
# ~/Hands-on-with-Ansible-Oct-2019/playbook/roles

vi webserver/templates/web.conf.j2
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

Our template is using variables that will be replaced with their values, at the time we run the playbook, and then sent off to the remote server.
Where is a good place to define variables? [Let's explore defining variables :nerd_face:](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#defining-variables-in-included-files-and-roles)

These variables belong to the `webserver` role. Their place is in a designed for the purpose location `webserver/vars/main.yml`:

```bash
# ~/Hands-on-with-Ansible-Oct-2019/playbook/roles

mkdir -p webserver/vars && vi webserver/vars/main.yml
```

Paste:

```YAML
server_admin_email: playground@localhost.local
server_document_root: /var/www/html
```

#### Tip! Check your [playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook) is correct!

### And now let's create and run our playbook

Do you remember the YAML that was showing high-level structure of a playbook? Let's create it.

```bash
cd .. && vi site.yml

# We are now back in playbook/
```

Paste:

```YAML
- name: LAMP stack setup and Wordpress installation on Ubuntu 18.04
  hosts: lamp
  remote_user: "{{ remote_username }}"
  become: yes
  
  roles:
    - role: common
    - role: webserver
    - role: db
    - role: php
    - role: wordpress
```

Let' set our remote user globally:

```bash
# in ~/Hands-on-with-Ansible-Oct-2019/playbook

echo remote_username: "playground" > group_vars/lamp.yml
```

#### You may want to check last time the  [playbook directory structure](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/hierarchy_structure.md#hierarchy-structure-of-playbook#hierarchy-structure-of-playbook)

And now run the playbook!

```bash
ansible-playbook -i inventory site.yml
```

Success! :+1: :+1: :+1:

#### Go to http://remote-tiger.ldn.devopsplayground.com/apache/wordpress

You should see:

![Wordpress welcome page](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/images/Screenshot%202019-10-19%20at%2013.23.54.png)

## 8. Playbook basics

### 8.1 How can we abbreviate the command we ran above?

Let's tell Ansible where we want it to look up the inventory.

```bash
# in ~/Hands-on-with-Ansible-Oct-2019/playbook

echo -e "inventory = inventory" >> ansible.cfg
```

Now run the playbook like this:

```bash
ansible-playbook site.yml
```

### 8.2 Linting

We can use the linter that comes with Ansible to catch bugs and stylistic errors. Especially helpful for those that start with Ansible but handy for experts as well.
Let's pull the linter down now:

```bash
sudo apt install ansible-lint
```

Run

```bash
ansible-lint site.yml
```

And watch the linter complain!

### 8.3 Dry-run

When ansible-playbook is executed with --check it will not make any changes on remote systems. Instead it will try to predict what changes it would make. This works great with `--diff` when you make small changes to files or templates.

```bash
ansible-playbook site.yml --check --diff
```

### 8.4 Tags

Playbooks can easily become large and can run for long time. We don't want to watch them rerun in their entirety every time we make a change to a task. How can we save time and run only what we are interested in? [Let's explore tags :nerd_face:](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)

```bash
vi site.yml
```

Delete all the contents in the file and paste the following.

```YAML
- name: LAMP stack setup and Wordpress installation on Ubuntu 18.04
  hosts: lamp
  remote_user: "{{ remote_username }}"
  become: yes
  
  roles:
    - role: common
    - role: webserver
      tags: [web]
    - role: db
      tags: [db]
    - role: php
    - role: wordpress
      tags: [wp, db]
```

Now run your playbook in the following mode:

```bash
ansible-playbook site.yml --tags=web
```

#### Hint! We placed `tags` on roles, but we can be more granular and tag any task in the playbook. 

:nerd_face: Only if you have time, modify a task file to bear a tag with your name. Then rerun the playbook with your tag to see only that task being played.

### 8.5 Enable Debug and Increase Verbosity

[Let's explore ways to debug :nerd_face:](https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html)

```bash
ANSIBLE_DEBUG=true ansible-playbook site.yml --tags=web  -v
# or
ANSIBLE_ENABLE_TASK_DEBUGGER=True ansible-playbook site.yml --tags=web  -v
```

This setting will trigger the debugger at any failed or unreachable task, unless specifically disabled.

The `-v` gives us a more detailed output for connection debugging. Ansible is rich with feedback data. Try running the same command but with `-vv` or even `-vvv`.

## 9. Notes

If you want to create the LAMP stack playbook from scratch, [here](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019/blob/master/step_by_step/LAMP_stack_step_by_step.md#ansible-hands-on).

## 10. References

Some materials were adopted from this cool book:

[Security Automation with Ansible 2: Leverage Ansible 2 to Automate Complex Security Tasks Like Application Security, Network Security, and Malware Analysis](https://g.co/kgs/xbJUnr)

## Thanks for participating!
