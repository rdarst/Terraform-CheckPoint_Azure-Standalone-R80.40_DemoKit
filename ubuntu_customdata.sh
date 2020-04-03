#!/bin/bash
until sudo apt-get update && sudo apt-get -y install apache2;do
    sleep 1
done
until curl \
    --output /var/www/html/CloudGuard.png \
    --url https://www.checkpoint.com/wp-content/uploads/cloudguard-hero-image.png ; do
    sleep 1
 done
 sudo chmod a+w /var/www/html/index.html
 echo "<html><head></head><body><center><H1>" > /var/www/html/index.html
 echo $HOSTNAME >> /var/www/html/index.html
 echo "<BR><BR>Check Point CloudGuard Terraform Demo <BR><BR>Any Cloud, Any App, Unmatched Security<BR><BR>" >> /var/www/html/index.html
 echo "<img src=\"/CloudGuard.png\" height=\"25%\">" >> /var/www/html/index.html
