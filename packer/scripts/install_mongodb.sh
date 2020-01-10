#!/bin/bash
set -e

#install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add -
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.6.list'
apt update -y
apt install -y mongodb-org
#systemctl start mongod
systemctl enable mongod
