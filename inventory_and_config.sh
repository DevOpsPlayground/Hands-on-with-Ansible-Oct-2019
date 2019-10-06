#!/bin/bash

host=${1}

if [ $# -eq 0 ]
  then
    echo -e "Remote host ip required.\nUsage:./create_inventory_and_config.sh 34.244.168.125"
    exit
fi

echo -e "[lamp]\nlampstack    ansible_host=${host}  ansible_become_pass=my_pass"  | tee -a ready_playbook/inventory playbook/inventory && 
echo -e "[defaults]\ninventory = inventory\nansible_python_interpreter=/usr/local/bin/python3" | tee -a ready_playbook/ansible.cfg playbook/ansible.cfg
