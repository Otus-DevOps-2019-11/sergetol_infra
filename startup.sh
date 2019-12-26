#!/bin/bash

#install Ruby and Bundler
apt update -y
apt upgrade -y
apt install -y ruby-full ruby-bundler build-essential

#install and start MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | sudo apt-key add -
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.6.list'
apt update -y
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod

#install and start reddit app
cd ~
rm -fr reddit
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
