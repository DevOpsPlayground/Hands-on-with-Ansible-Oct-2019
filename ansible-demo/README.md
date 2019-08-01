# ANSIBLE MINI - PLAYGROUND

db_host = 'your.host.ip'
yuliya_host=34.244.168.125

1. Install Ansible
    If you already have Homebrew installed on your mac, then 

    ```brew install ansible```

That's it!

If you prefer to use Python and pip for the install, then read on...
    
- [Install XCode](https://developer.apple.com/xcode/)
- sudo easy_install pip
- sudo pip install ansible --quiet



2. Set up your structure
$ git clone git@github.ecs-digital.co.uk:ECSD/hsbc_patching_pod.git
$ ./setup.sh







4. Run the playbook
ansible-playbook playbook.yml