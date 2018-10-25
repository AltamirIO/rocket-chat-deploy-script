#!/bin/bash



function testInstalled {
    if `dpkg-query -W $1 | grep -q "no packages found"`; then
        echo "in if"
        return 1;
    fi
    echo "failed if"
    return 0;
}

echo "LOCATION $1"
cd $1

# test that docker-compose and docker are installed

! testInstalled docker-compose && apt update; apt install -y docker-compose;
! testInstalled docker && apt update; apt install -y docker;

source ./.env

#configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 443/tcp

cp ./hosts /etc/hosts

crontab -l | { cat; echo "@daily certbot renew --pre-hook \"docker-compose -f /opt/docker-compose.yml down\" --post-hook \"docker-compose -f /opt/docker-compose.yml up -d\""; } | crontab -
certbot -n -d $2;
systemctl start docker;
systemctl enable docker;

#if the system was unable to start docker, restart
# ! systemctl is-active --quiet docker && exit 1;
docker-compose down
docker-compose up -d rocketchat
docker-compose up -d mongo
docker-compose up -d mongo-init-replica
docker-compose up -d nginx
ufw --force enable
exit;