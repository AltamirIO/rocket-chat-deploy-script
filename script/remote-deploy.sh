#!/bin/bash



function testInstalled {
    if `dpkg-query -W $1 | grep -q "no packages found"`; then
        echo "in if"
        return 1;
    fi
    echo "failed if"
    return 0;
}
cd $1/
mv script/* ./
source ./.env

echo "IP ADDR $IP"

# test that docker-compose and docker are installed
apt update;
apt install docker-compose docker ufw certbot;

#configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 443/tcp

# Comment if using LetsEncrypt
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certificate.key -out /etc/nginx/certificate.crt
export SSL_CERT_LOCATION=/etc/nginx/certificate.crt
export SSL_KEY_LOCATION=/etc/nginx/certificate.key

# Uncomment for LetsEncrypt certification
# certbot certonly --standalone -n -d $DOMAIN --email $DOMAIN_CONTACT --agree-tos;
# export SSL_CERT_LOCATION=/etc/letsencrypt/live/$DOMAIN/fullchain.pem
# export SSL_KEY_LOCATION=/etc/letsencrypt/live/$DOMAIN/privkey.pem
# crontab -l | { cat; echo "@daily certbot renew --pre-hook \"docker-compose -f $LOCATION/docker-compose.yml down\" --post-hook \"docker-compose -f $LOCATION/docker-compose.yml up -d\""; } | crontab -

DOMAIN=$DOMAIN SSL_CERT_LOCATION=$SSL_CERT_LOCATION SSL_KEY_LOCATION=$SSL_KEY_LOCATION envsubst < nginx.conf > nginx.conf;
cat nginx.conf;
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