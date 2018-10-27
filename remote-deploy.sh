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

ufw disable

#configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 443/tcp

mkdir -p certs

# Comment if using LetsEncrypt
# openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
#     -subj "/C=US/ST=UT/L=Orem/O=Altamir/CN=$DOMAIN" \
#     -keyout certs/certificate.key  -out certs/certificate.cert
# export SSL_CERT_LOCATION=/opt/certs/certificate.cert
# export SSL_KEY_LOCATION=/opt/certs/certificate.key
source ./.env
export DOMAIN_NAME=$DOMAIN
# Uncomment for LetsEncrypt certification
certbot certonly --standalone -n -d $DOMAIN --email $DOMAIN_CONTACT --agree-tos;
export SSL_CERT_LOCATION=/etc/letsencrypt/live/$DOMAIN/fullchain.pem
export SSL_KEY_LOCATION=/etc/letsencrypt/live/$DOMAIN/privkey.pem

crontab -l | { cat; echo "@daily certbot renew --pre-hook \"docker-compose -f $LOCATION/docker-compose.yml down\" --post-hook \"docker-compose -f $LOCATION/docker-compose.yml up -d\""; } | crontab -

envsubst '\$DOMAIN_NAME \$SSL_CERT_LOCATION \$SSL_KEY_LOCATION \$APPLICATION_PORT' < nginx.default.conf > nginx.conf;
cat nginx.conf;
systemctl start docker;
systemctl enable docker;

#if the system was unable to start docker, restart
# ! systemctl is-active --quiet docker && exit 1;
docker-compose down
docker-compose up -d
ufw --force enable
exit;