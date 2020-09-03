#!/bin/sh
#
#Nginx reverse proxy and LetsEncrypt
#
read -p 'Enter domain name: ' domain
read -p 'Enter server port number: ' port
apt-get update && apt -y install nginx
systemctl enable nginx.service && systemctl start nginx.service
cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/original
#tail -13 /etc/nginx/sites-enabled/original > $domain
cat < EOF | tee -a /etc/nginx/sites-enabled/change.com
      ##Virtual Host
	server {
        listen 80;
        listen [::]:80;

        root /var/www/example.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name example.com www.example.com;

        location / {
                try_files $uri $uri/ =404;
        }
}
EOF
mv $domain /tmp/file.txt
cd /tmp
#sed -i 's/#/ /g' file.txt
#sed -i '7d;8d' file.txt
sed -i "s/example.com/$domain/g" file.txt
sed -i 's/try_files $uri $uri\/ =404/proxy_pass http:\/\/127.0.0.1:port/g' file.txt
sed -i "s/port/$port/g" file.txt
cat file.txt
mv file.txt /etc/nginx/sites-enabled/$domain
apt install -y python3-certbot-nginx && certbot --nginx 
service nginx restart
