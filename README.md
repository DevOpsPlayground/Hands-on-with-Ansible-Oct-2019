# ANSIBLE HANDS-ON

#### Our task:

### Still working on deciding which one!

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

2. The __web terminal - WeTTy__ can be accessed via web browser by typing \<\<instance-address\>\>/wetty i.e *<http://control_\<\<your_animal\>\>.ldn.devopsplayground.com/wetty/*>

3. The password for both  is the one on your leaflet.

From now on we will be working from the browsers only.

4. Type some shell commands to get at ease with the web terminal.
        


#### 1. Install Ansible (if you haven't already)

Check whether Ansible is installed by running:
        
        $ ansible --version

If it isn't, run these commands:
        
        $ sudo apt update
        $ sudo apt install python3-pip
        $ pip3 --version
        $ sudo pip3 install ansible --quiet

That's it!

#### 2. Configuring SSH Access to the remote Host. 

Fire up 

Run the following command from your command line from your . When prompted for password type in the password provided to you along with the hostnames.

        $ ./setup.sh <your remote host IP>   

#### 3. Let's check out connectivity with the host. Run:
        $ cd ansible_hands_on
        $ ansible all -i 'host.ip,' -m ping    
##### Example:   
        $ ansible all -i '52.214.226.94,' -m ping

 Or check memory and disk space of your host:

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


#### 6. Run the playbook

        ansible-playbook  -i ./ansible_inventory update.yml


#### 7. Deploy an app

    Lorem ipsum...  

#### 8. Oh no! Someone messed up my configuration!


#### 9. Notes

    
Link to the [git repository](https://github.com/DevOpsPlayground/Hands-on-with-Ansible-Oct-2019) with the README and the playbooks that will be used in this session.

#### 10. References

Some materials were adopted form this cool book:

[Security Automation with Ansible 2: Leverage Ansible 2 to Automate Complex Security Tasks Like Application Security, Network Security, and Malware Analysis](https://g.co/kgs/xbJUnr)

 

# Thanks for participating!