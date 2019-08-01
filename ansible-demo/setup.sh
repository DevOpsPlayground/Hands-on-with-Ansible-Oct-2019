#!/bin/bash

host=${1}

if [ $# -eq 0 ]
  then
    echo -e "Remote host ip required.\nUsage:./setup.sh 34.244.168.125"
    exit
fi

mkdir -p ~/ansible-demo && cd ~/ansible-demo
echo -e "[db_hosts]\n${host}" > ansible_inventory && echo -e "[inventory]\ninventory = ansible_inventory\nansible_path=/usr/local/bin/python3" > ansible.cfg
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@${host}
