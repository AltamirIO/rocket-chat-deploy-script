#!/bin/bash

source ./.env
#test change 
echo "IP ADDRESS: $IP"
scp docker-compose.yml root@104.248.218.40:$LOCATION

rsync -rv --exclude=.git . root@$IP:$LOCATION

ssh root@104.248.218.40 'bash -s' < ./remote-deploy.sh $LOCATION $DOMAIN