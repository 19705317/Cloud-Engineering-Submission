#!/bin/bash

# update
sudo apt update -y

# upgrade (completely noninteractive)
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# install nginx
sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y

# install pm2
sudo npm install -g pm2

# download noadjs shell script
curl -fsSL https://deb.nodesource.com/setup_20.x -o setup_nodejs.sh

# run setup_nodejs.sh (bash is used to run the file) (this readies all the files)
sudo DEBIAN_FRONTEND=noninteractive bash setup_nodejs.sh

# sudo apt-get install nodejs (use "node -v" to get version)
sudo DEBIAN_FRONTEND=noninteractive apt-get install nodejs -y

# export DB connection
export DB_HOST=mongodb://10.0.3.4:27017/posts

# setup reverse proxy
sudo sed -i 's|try_files.*;|proxy_pass http://localhost:3000/;|' /etc/nginx/sites-available/default

# restart nginx
sudo systemctl restart nginx

# clone app repo
git clone https://github.com/daraymonsta/tech201-sparta-app /repo

# install npm
cd /repo/app
npm install

#run app
pm2 start app.js
 

 