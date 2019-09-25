#!/bin/bash

host=${1}

if [ $# -eq 0 ]
  then
    echo -e "Remote host ip required.\nUsage:./create_inventory_and_config.sh 34.244.168.125"
    exit
fi

echo -e "[lamp]\nlampstack    ansible_host=${host}" > playbook/ansible_inventory.ini && 
echo -e "[defaults]\ninventory = ansible_inventory\nansible_path=/usr/local/bin/python3" > playbook/ansible.cfg