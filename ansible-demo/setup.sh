#!/bin/bash

mkdir -p ~/ansible-demo && cd ~/ansible-demo

echo "db_host" > ansible_inventory && echo "inventory = ansible_inventory" > ansible.cfg