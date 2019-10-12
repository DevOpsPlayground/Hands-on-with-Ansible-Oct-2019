#!/bin/bash

if [ -z "$REMOTE_HOST" ]
  then
    echo -e "Make sure you've set the environment variable REMOTE_HOST"
    exit
fi

if [ -z "$PASSWORD" ]
  then
    echo -e "Make sure you've set the environment variable PASSWORD"
    exit
fi

inventory_content="[lamp]\nlampstack    ansible_host=${REMOTE_HOST}  ansible_become_pass=${PASSWORD}"
ansible_cfg_content="[defaults]\ninventory = inventory\nansible_python_interpreter=/usr/local/bin/python3"


echo -e  $inventory_content | tee ready_playbook/inventory playbook/inventory 1>/dev/null
echo -e  $ansible_cfg_content | tee ansible.cfg ready_playbook/ansible.cfg playbook/ansible.cfg 1>/dev/null

echo "Creating inventory and ansible.cfg......"
echo "Done"
