#!/bin/bash

sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

sudo apt update

sudo apt install nginx jq -y

sudo systemctl start nginx && sudo systemctl enable nginx

echo "server {
    listen 443 ssl;
    ssl_certificate /etc/certs/live/kikrr.cloud/fullchain.pem;
    ssl_certificate_key /etc/certs/live/kikrr.cloud/privkey.pem;
    server_name  $1;

    location / {
    proxy_pass         http://localhost:8080/;
    proxy_http_version 1.1;
    proxy_set_header   Upgrade \$http_upgrade;
    proxy_set_header   Connection keep-alive;
    proxy_set_header   Host \$host;
    proxy_cache_bypass \$http_upgrade;
    proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}" | sudo tee /etc/nginx/sites-available/guacamole.conf 

sudo ln -s /etc/nginx/sites-available/guacamole.conf /etc/nginx/sites-enabled

sudo nginx -t
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /etc/nginx/sites-available/default

sudo systemctl restart nginx

echo 'PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config
echo 'HostKeyAlgorithms +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd