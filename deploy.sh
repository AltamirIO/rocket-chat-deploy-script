#!/bin/bash

source ./.env
#test change 
echo "IP ADDRESS: $IP"
scp docker-compose.yml root@$IP:$LOCATION

rsync -rv --exclude=.git . root@$IP:$LOCATION

ssh root@$IP 'bash -s' < ./remote-deploy.sh $LOCATION $DOMAIN