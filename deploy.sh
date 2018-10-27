#!/bin/bash

source ./.env
#test change 
echo "IP ADDRESS: $IP"
echo $LOCATION
rsync -rv --progress --exclude=.git ./ root@$IP:$LOCATION;

ssh root@$IP 'bash -s' < ./remote-deploy.sh $LOCATION