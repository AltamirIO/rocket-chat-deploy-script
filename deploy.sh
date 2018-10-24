#!/bin/bash

LOCATION=/opt
DOMAIN=104.248.218.40

#test change 
echo "IP ADDRESS: $DOMAIN"
scp docker-compose.yml root@104.248.218.40:$LOCATION

rsync -rv --exclude=.git . root@$DOMAIN:$LOCATION

ssh root@104.248.218.40 'bash -s' < ./remote-deploy.sh $LOCATION