#!/bin/bash

if [ -z "$REMOTE_HOST" ]
  then
    echo -e "Make sure you've set the environment variable REMOTE_HOST"
    exit
fi

# # set ssh connection to your host
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
eval `ssh-agent -s`
ssh-add $SSH_KEY_NAME
ssh-copy-id -i ~/.ssh/id_rsa.pub playground@${REMOTE_HOST}
