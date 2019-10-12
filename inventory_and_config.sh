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

echo -e "[lamp]\nlampstack    ansible_host=${REMOTE_HOST}  ansible_become_pass=${PASSWORD}"  | tee ready_playbook/inventory playbook/inventory && 
echo -e "[defaults]\ninventory = inventory\nansible_python_interpreter=/usr/local/bin/python3" | tee ansible.cfg ready_playbook/ansible.cfg playbook/ansible.cfg
