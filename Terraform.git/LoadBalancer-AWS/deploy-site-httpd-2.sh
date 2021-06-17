#!/bin/bash
sudo yum install httpd -y
sudo echo "<html><body><h1>Hello from server 2!</h1></body></html>" > /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl restart httpd
