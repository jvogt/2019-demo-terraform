#!/bin/bash

sudo mkdir -p /hab/accepted-licenses
mkdir -p ~/.hab/accepted-licenses
sudo touch ~/.hab/accepted-licenses/habitat
sudo touch /hab/accepted-licenses/habitat
hostnamectl set-hostname ${habitat_depot_hostname}
sysctl -w vm.max_map_count=262144
sysctl -w vm.dirty_expire_centisecs=20000
apt-get --assume-yes install git
git clone https://github.com/habitat-sh/on-prem-builder.git /tmp/on-prem-builder.git
cp /tmp/bldr.env /tmp/on-prem-builder.git/bldr.env
chmod +x /tmp/on-prem-builder.git/install.sh
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=WA/L=Seattle/O=Sample/CN=${habitat_depot_hostname}" -keyout /tmp/on-prem-builder.git/ssl-certificate.key  -out /tmp/on-prem-builder.git/ssl-certificate.crt
cd /tmp/on-prem-builder.git
echo y | ./install.sh

echo "[server]
ssl_ciphers = 'EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA512:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:ECDH+AESGCM:ECDH+AES256:DH+AESGCM:DH+AES256:RSA+AESGCM:!aNULL:!eNULL:!LOW:!RC4:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS'
" > /tmp/ciphers.toml
hab config apply builder-api-proxy.default $(date +%s) /tmp/ciphers.toml

# sleep 60
# ## PGPASSWORD=$(sudo cat /hab/svc/builder-datastore/config/pwfile) hab pkg exec core/postgresql pg_dump -h 127.0.0.1 -p 5432 -U hab builder > builder.sql
# PGPASSWORD=$(sudo cat /hab/svc/builder-datastore/config/pwfile) hab pkg exec core/postgresql psql -h 127.0.0.1 -p 5432 -U hab -d builder -f /tmp/origin-setup.sql

# rm -rf /hab/svc/builder-api/files/*

# NDATE=$(date +"%Y%m%d%H%M%S") 

# echo -n "BOX-SEC-1
# bldr-$NDATE

# gK/h8AyxBJEbnskAHBO8FiHECV1XLvZ4/c2k+XMHL8U=" > /tmp/bldr-$NDATE.box.key

# hab file upload builder-api.default $NDATE /tmp/bldr-$NDATE.box.key


# echo -n "BOX-PUB-1
# bldr-$NDATE

# X6hEIVgnxdbFy0M3PiSw5GEuD6UO5ckMzvaQOcAN2mg=" > /tmp/bldr-$NDATE.pub

# hab file upload builder-api.default $NDATE /tmp/bldr-$NDATE.pub

# service hab-sup restart
# run syn