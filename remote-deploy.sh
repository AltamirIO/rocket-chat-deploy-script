#!/bin/bash



function testInstalled {
    if `dpkg-query -W $1 | grep -q "no packages found"`; then
        echo "in if"
        return 1;
    fi
    echo "failed if"
    return 0;
}

echo $(testInstalled docker)

cd $1

# test that docker-compose and docker are installed

! testInstalled docker-compose && apt update; apt install -y docker-compose;
! testInstalled docker && apt update; apt install -y docker;

systemctl start docker;
systemctl enable docker;

#if the system was unable to start docker, restart
! systemctl is-active --quiet docker && exit 1;

#start mongodb
docker-compose up -d mongo

#start mongodb replicator
docker-compose up -d mongo-init-replica

#stop the current rocketchat instance, delete it, and bring up the new image
docker-compose stop rocketchat
docker-compose rm -f rocketchat
docker-compose up -d rocketchat