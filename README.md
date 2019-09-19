# ANSIBLE HANDS-ON

### Our task:

#### Reboot Ubuntu Linux machine using shell or command module and wait for it to come back.

### You will need:

    1.  Ansible
    2.  A remote host
        Example: 34.244.168.125
------
### Let's start
#### 1. Install Ansible (if you haven't already)
    If you are not sure, you can check whether Ansible is installed by running:
        
        $ ansible --version

- [Install XCode](https://developer.apple.com/xcode/) REAALLY?? (if you haven't already), then run:
        
        $ sudo apt update
        $ sudo apt install python3-pip
        $ pip3 --version
        $ sudo pip3 install ansible --quiet

    That's it!

#### 2. Inital setup. 

    An AWS PEM file contains a private key.  
    Should each user be provided with a pem file? 

    Shouldn't the PEM file be used for the participants to connect with their 2 boxes?

    Should I make them generate an ssh key?

    Then set ssh connection to their  remote_host

            $ ssh-add "generated_rsa.pub"
            $ ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@${host}

#### 3. Let's check out connectivity with the host. Run:

        $ ansible all -i 'host.ip,' -m ping    # Example:   ansible all -i '52.214.226.94,' -m ping
    Or check memory and disk space of your host:

        $ ansible all -i 'host.ip,' -m shell -a 'free -m && df -h '

#### 4. Hostfile

    Lorem ipsum.....

#### 5. Write a simple playbook.

We will put together a simple playbook to update our remote host. 
Create a file `update.yml` and paste the following. Careful with the spaces - YAML is fussy! 
    
HINT: You can copy the file you have cloned from the repo. 

        ---
        - hosts: db_hosts
          tasks:
            - name: Update all packages on a Debian/Ubuntu
              apt:
                update_cache: yes
                upgrade: dist


#### 6. Run the playbook

        ansible-playbook  -i ./ansible_inventory update.yml


# Thanks for participating!