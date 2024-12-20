#!/bin/bash

# update vm packages
sudo apt update -y

# upgrade packages
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# import mongodb public key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

# create mongoDB list file
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# update the mongoDB package
sudo apt-get update

# download specific version of mongoDB
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6

# change config of mongod local ip to default gateway
sudo sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf 

# restart mongoDB to change configuration
sudo systemctl restart mongod

# manually delete 27017 from sock file due to permission issues
sudo rm -rf /tmp/mongodb-27017.sock

# enable mongodb
sudo systemctl enable mongod