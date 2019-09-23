# ANSIBLE HANDS-ON

#### Our task:

### Create a real-world LAMP stack for development using Ansible.

#### You will need:

1. Your leaflet your picked up at reception.
2. Chrome preferably but Firefox can also do.
3. __*Panda*__ with us and have fun!!!

------
### Let's start

You have each been given an animal. Bob is a duck.

Also we have setup two machines for you to access via a command line in the browser:

        http://control_duck.ldn.devopsplayground.com/wetty/
        http://remote_duck.ldn.devopsplayground.com/wetty/

These will be used as the Ansible Control Node and Ansible Remote Host, respectively.

1. Fire up your browser - one window for each machine.

2. The __web terminal - WeTTy__ can be accessed via web browser by typing \<\<instance-address\>\>/wetty i.e 
        
       http://control_<<your_animal>>.ldn.devopsplayground.com/wetty/

3. The password for both  is the one on your leaflet.

4. Type some shell commands to get at ease with the web terminal.

From now on we will be working from the browsers only.

-----

#### 1. Install Ansible (if you haven't already)

Check whether Ansible is installed by running:
        
        $ ansible --version
You should see something like:

        ansible 2.6.5

If not, run these commands:
        
        $ sudo apt update
        $ sudo apt install python3-pip
        $ pip3 --version
        $ sudo pip3 install ansible --quiet
and
        
        $ ansible --version

That's it!

#### 2. Configuring SSH Access to the remote Host. 

Run the following command from your control_duck.

        $ ./setup.sh <your remote host IP>   

#### 3. Let's check out connectivity with the host. Run:
        $ cd ansible_hands_on
        $ ansible all -i 'host.ip,' -m ping    
##### Example:   
        $ ansible all -i '52.214.226.94,' -m ping

 Or check memory and disk space on your remote_duck:

        $ ansible all -i 'host.ip,' -m shell -a 'free -m && df -h'

#### 4. Hostfile and Configuration file

        $ ./inventory_and_config.sh <your remote host IP>

#### 5. Write a simple playbook.

We will put together a simple playbook to update our remote host. 
Create a file `update.yml` and paste the following. Careful with the spaces - YAML is fussy! 
    
HINT: You can copy the file you have cloned from the repo. 

        ---
        - hosts: web
          tasks:
            - name: Update all packages on a Debian/Ubuntu
              apt:
                update_cache: yes
                upgrade: dist
        
          tasks:
            - name: Check disk space and memory
              shell: free -m && df -h


#### 6. Run the playbook

        ansible-playbook  -i ./ansible_inventory update.yml


#### 7. Build a LAMP stack

We will look at how to write a LAMP stack playbook using the features offered by Ansible. Here is the high-level hierarchy structure of the playbook that will trigger the installation of LAMP:

        - name: LAMP stack setup on Ubuntu 18.04
          hosts: lamp
          gather_facts: False
          remote_user: "{{ remote_username }}"
          become: True
          roles:
            - common
            - web
            - db
            - php 

##### 7.1 The Common Role

##### Questions: Do we need to install Python 2 if we already will have installed Python 3? (Currently Python 2 is installed)

Create the folowing folder structure `roles/common/tasks/main.yml` and put in the `main.yml` the following contents: 

        - name: install python 2
          raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)
        - name: install curl and git
          apt:
            name: "{{ item }}"
            state: present
            update_cache: yes
          with_items:
            - curl
            - git

  

What if we don't have access to the documentation in the web? Ansible ships with the `ansible-doc` tool. We can access the documentation from the command line.

        $ ansible-doc apt


#### 8. Oh no! Someone messed up my configuration!





#### 9. Notes

    
Link to the [git repository](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019) with the README and the playbooks that will be used in this session.

#### 10. References

Some materials were adopted form this cool book:

[Security Automation with Ansible 2: Leverage Ansible 2 to Automate Complex Security Tasks Like Application Security, Network Security, and Malware Analysis](https://g.co/kgs/xbJUnr)

 

# Thanks for participating!