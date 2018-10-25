#!/bin/bash

source ./script/.env
#test change 
echo "IP ADDRESS: $IP"
echo $LOCATION
scp -r script/ root@$IP:$LOCATION;

ssh root@$IP 'bash -s' < ./script/remote-deploy.sh $LOCATION