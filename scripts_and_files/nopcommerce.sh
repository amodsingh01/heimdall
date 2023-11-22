#!/bin/bash

wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

sudo dpkg -i packages-microsoft-prod.deb

sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

sudo apt update

sudo apt install -y apt-transport-https aspnetcore-runtime-7.0

sudo apt install nginx -y

sudo systemctl start nginx && sudo systemctl enable nginx

echo "server {
    listen 443 ssl;
    ssl_certificate /etc/certs/live/kikrr.cloud/fullchain.pem;
    ssl_certificate_key /etc/certs/live/kikrr.cloud/privkey.pem;
    server_name  $1;

    location / {
    proxy_pass         http://localhost:5000;
    proxy_http_version 1.1;
    proxy_set_header   Upgrade \$http_upgrade;
    proxy_set_header   Connection keep-alive;
    proxy_set_header   Host \$host;
    proxy_cache_bypass \$http_upgrade;
    proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}" | sudo tee /etc/nginx/sites-available/nopcommerce.conf 

sudo ln -s /etc/nginx/sites-available/nopcommerce.conf /etc/nginx/sites-enabled

sudo nginx -t
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /etc/nginx/sites-available/default

sudo mkdir /var/www/nopCommerce

cd /var/www/nopCommerce

sudo wget https://github.com/nopSolutions/nopCommerce/releases/download/release-4.60.1/nopCommerce_4.60.1_NoSource_linux_x64.zip

sudo apt install unzip -y

sudo unzip nopCommerce_4.60.1_NoSource_linux_x64.zip

sudo mkdir bin
sudo mkdir logs
cd ..
sudo chgrp -R www-data nopCommerce/
sudo chown -R www-data nopCommerce/

echo "[Unit]
Description=Example nopCommerce app running on Xubuntu

[Service]
WorkingDirectory=/var/www/nopCommerce
ExecStart=/usr/bin/dotnet /var/www/nopCommerce/Nop.Web.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=nopCommerce-example
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/nopCommerce.service

sudo systemctl start nopCommerce.service && sudo systemctl enable nopCommerce.service


sudo systemctl restart nginx

echo 'PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config
echo 'HostKeyAlgorithms +ssh-rsa' | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd
sleep 20