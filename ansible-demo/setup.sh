#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

mkdir -p ~/ansible-demo && cd ~/ansible-demo

echo ${1} > ansible_inventory && 
echo "inventory = ansible_inventory" > ansible.cfg