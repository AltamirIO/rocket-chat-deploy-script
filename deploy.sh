#!/bin/bash

LOCATION=/opt

scp docker-compose.yml root@104.248.218.40:$LOCATION

ssh root@104.248.218.40 'bash -s' < ./remote-deploy.sh $LOCATION