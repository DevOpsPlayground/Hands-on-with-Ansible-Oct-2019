#!/bin/bash

host=${1}

if [ $# -eq 0 ]
  then
    echo -e "Remote host ip required.\nUsage:./setup.sh 34.244.168.125"
    exit
fi

# Settin up a separate folder to run the entire session from.
mkdir ansible_hands_on && cd ansible_hands_on
pwd
mv ../ansible-demo/yuliya_ans.pem .
echo -e "[db_hosts]\n${host}" > ansible_inventory && echo -e "[defaults]\ninventory = ansible_inventory\nansible_path=/usr/local/bin/python3" > ansible.cfg

# set ssh connection to your host
ssh-add "yuliya_ans.pem"
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@${host}
