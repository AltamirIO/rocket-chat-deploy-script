#!/bin/bash

source ./.env
#test change 
echo "IP ADDRESS: $IP"
echo $LOCATION
rsync --progress --exclude=.git ./ root@$IP:$LOCATION;

ssh root@$IP "bash -s /$LOCATION/remote-deploy.sh"