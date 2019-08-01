#!/bin/bash

host=${1}

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

mkdir -p ~/ansible-demo && cd ~/ansible-demo
echo ${host} > ansible_inventory && echo -e "[inventory]\ninventory = ansible_inventory\nansible_path=/usr/local/bin/python3" > ansible.cfg
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@${host}
