#!/bin/bash

host=${1}

if [ $# -eq 0 ]
  then
    echo -e "Remote host ip required.\nUsage:./setup.sh 34.244.168.125"
    exit
fi

mkdir ansible_hands_on && cd ansible_hands_on
echo -e "[db_hosts]\n${host}" > ansible_inventory && echo -e "[defaults]\ninventory = ansible_inventory\nansible_path=/usr/local/bin/python3" > ansible.cfg
# go back to ansible-demo
cd -


# set ssh connection to your host
ssh-add "yuliya_ans.pem"
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@${host}
