#!/bin/bash

USER_ID=$(id -u $USER)
GROUP_ID=$(id -g $USER)

# Create directories
mkdir -p logs/nginx logs logs/php app app/logs app/public data/nginx/cache data/nginx/temp
mkdir -p data/mysql data/redis

# Clone nginx config files
git clone https://github.com/flywp/config.git config

mkdir -p config/nginx/custom/before config/nginx/custom/after config/nginx/custom/server

# Create env file
cat >".env" <<EOF
USER_ID=$USER_ID
GROUP_ID=$GROUP_ID
PORT=8080
EOF

# Create default nginx config
cat >"config/nginx/default.conf" <<"EOF"

# Custom configs
include custom/before/*.conf;

server {
    listen 80;
    listen [::]:80;
    server_name local-docker-site.test;


    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;

    root /var/www/html/public;

    index index.php index.html;

    # Custom configs
    include custom/server/*.conf;

    include common/locations.conf;

    # 7G Firewall
    include common/7g.conf;

    # WP Blocking rules
    include common/block-links-opml.conf;
    include common/block-wpincludes.conf;
    include common/block-wpcontent.conf;
    include common/block-xmlrpc.conf;
    include common/block-feed.conf;
    include common/block-trackback.conf;

    # Execute PHP
    include common/php.conf;
}

# Custom configs
include custom/after/*.conf;

EOF

# Ask the user if they want to download WordPress
read -p "Do you want to download WordPress? (y/n) " download_answer

download_answer=$(echo "$download_answer" | tr '[:upper:]' '[:lower:]')

if [[ "$download_answer" == "y" || "$download_answer" == "yes" ]]; then
    echo "Downloading WordPress..."
    curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
    echo "Extracting WordPress..."
    tar -xzf wordpress.tar.gz -C ./app/public --strip-components=1
    rm wordpress.tar.gz
    echo "WordPress downloaded and extracted to ./app/public"
else
    echo "<?php phpinfo();" >app/public/index.php
fi

# Ask the user if they want to add an entry to /etc/hosts
read -p "Do you want to add an entry to /etc/hosts? (y/n) " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
    # Add the entry to /etc/hosts
    echo "127.0.0.1 local-docker-site.test" | sudo tee -a /etc/hosts
    echo "Entry added to /etc/hosts."
else
    echo "No changes made to /etc/hosts."
fi

echo "Done!"
