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
ansible_cfg_content="ansible_python_interpreter=/usr/local/bin/python3"


echo -e  $inventory_content | tee playbook/inventory 1>/dev/null
echo -e  $ansible_cfg_content | tee ansible.cfg playbook/ansible.cfg 1>/dev/null

echo "Creating inventory of hosts and ansible.cfg......"
echo "Done!"
