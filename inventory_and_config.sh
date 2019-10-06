#!/bin/bash

host=${1}

if [ $# -eq 0 ]
  then
    echo -e "Remote host ip required.\nUsage:./create_inventory_and_config.sh 34.244.168.125"
    exit
fi
mkdir playbook
echo -e "[lamp]\nlampstack    ansible_host=${host}  ansible_become_pass=my_pass" > ready_playbook/inventory && 
echo -e "[defaults]\ninventory = ansible_inventory\nansible_python_interpreter=/usr/local/bin/python3" > ready_playbook/ansible.cfg

echo -e "[lamp]\nlampstack    ansible_host=${host}  ansible_become_pass=my_pass" > inventory && 
echo -e "[defaults]\ninventory = ansible_inventory\nansible_python_interpreter=/usr/local/bin/python3" > ansible.cfg