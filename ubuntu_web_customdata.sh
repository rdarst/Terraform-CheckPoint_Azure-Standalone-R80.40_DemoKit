#!/bin/bash
# Update and download Nginx
until sudo apt-get update && sudo apt-get -y install nginx;do
    sleep 1
done
# Download the CloudGuard Logo
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

# Download the CPnanoAgent
until curl \
    --output /home/chkpuser/cp-nano-egg.sh \
    --url https://chkpscripts.s3.amazonaws.com/cp-nano-egg.sh ; do
    sleep 1
done

# Install Nano Agent
sudo chmod 755 /home/chkpuser/cp-nano-egg.sh
sudo /home/chkpuser/cp-nano-egg.sh --install --ignore accessControl --token <<TOKEN_FROM_Infinity_Next_Portal>> --fog_address https://i2-agents.cloud.ngen.checkpoint.com

