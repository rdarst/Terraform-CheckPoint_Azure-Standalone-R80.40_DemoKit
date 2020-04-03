#!/bin/bash
clish -c 'set user admin shell /bin/bash' -s
clish -c 'set static-route 10.95.11.0/24 nexthop gateway address 10.95.1.1 on' -s
config_system -s 'install_security_gw=true&install_ppak=true&gateway_cluster_member=false&install_security_managment=true&install_mgmt_primary=true&install_mgmt_secondary=false&download_info=true&hostname=R80dot40mgmt&mgmt_gui_clients_radio=any&mgmt_admin_radio=gaia_admin'
/opt/CPvsec-R80.40/bin/vsec on
sleep 5
#Setup Initial file to wait for R80 to be ready and setup the API/Rules after the first boot
cat <<EOT >> /etc/rc.local
## This is only used once for initial setup of the Azure instance
if [[ -f "/home/admin/R80setup" ]]
then
/home/admin/R80setup
fi
EOT

touch /home/admin/R80setup
chmod 755 /home/admin/R80setup
cat <<EOT >> /home/admin/R80setup
#!/bin/bash
while true; do
    status=\$(api status |grep 'API readiness test SUCCESSFUL. The server is up and ready to receive connections' |wc -l)
    echo "Checking if the API is ready"
    if [[ ! \$status == 0 ]]; then
         break
    fi
       sleep 15
    done
echo "API ready " \$(date)
sleep 5
echo "Set R80 API to accept all ip addresses"
mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" --domain 'System Data'
echo "Add user api_user with password vpn123"
mgmt_cli -r true add administrator name "api_user" password "Cpwins123" must-change-password false authentication-method "INTERNAL_PASSWORD" permissions-profile "Super User" --domain 'System Data'
## Setup rules for use in Demo
SID=\$(mgmt_cli -r true login -f json | jq -r '.sid')
mgmt_cli --session-id \$SID add network name "AzureInternal" subnet "10.95.1.0" mask-length 24 nat-settings.auto-rule true nat-settings.method "hide" nat-settings.hide-behind "gateway"  --format json
mgmt_cli --session-id \$SID add network name "AzureDMZ" subnet "10.95.11.0" mask-length 24 nat-settings.auto-rule true nat-settings.method "hide" nat-settings.hide-behind "gateway"  --format json
mgmt_cli --session-id \$SID add-host name "UbuntuWeb" ip-address "10.95.11.100" --format json
mgmt_cli --session-id \$SID add group name "InternalNetworks" members.1 "AzureInternal" members.2 "AzureDMZ" --format json
mgmt_cli --session-id \$SID add-service-tcp name "TCP_8090" port 8090
mgmt_cli --session-id \$SID add access-rule layer "Network" position "top" name "Internal Access" destination "InternalNetworks" source "InternalNetworks" action "Accept" track "Log" --format json
mgmt_cli --session-id \$SID add access-rule layer "Network" position.below "Internal Access"  name "Internet Access" source "InternalNetworks" action "Accept" track "Log" --format json
mgmt_cli --session-id \$SID add access-rule layer "Network" position.below "Internet Access"  name "Mgmt Access" destination "R80dot40mgmt" action "Accept" service.1 https service.2 ssh service.3 "TCP_8090" track "Log" --format json
mgmt_cli --session-id \$SID set-access-rule layer "Network" name "Cleanup rule" track "Log" --format json
mgmt_cli --session-id \$SID set-simple-gateway name R80dot40mgmt url-filtering true ips true anti-bot true anti-virus true application-control true content-awareness true
mgmt_cli --session-id \$SID set-simple-gateway name R80dot40mgmt interfaces.1.name eth0 interfaces.1.topology external interfaces.1.ip-address 10.95.0.10 interfaces.1.mask-length 24 interfaces.2.name eth1 interfaces.2.topology internal interfaces.2.topology-settings.ip-address-behind-this-interface "network defined by routing" interfaces.2.ip-address 10.95.1.10 interfaces.2.mask-length 24
mgmt_cli --session-id \$SID add-nat-rule package "Standard" position "top" original-destination "R80dot40mgmt" original-service "TCP_8090" translated-destination "UbuntuWeb" translated-service "http"
mgmt_cli --session-id \$SID publish
mgmt_cli --session-id \$SID run-ips-update
mgmt_cli --session-id \$SID publish
mgmt_cli --session-id \$SID install-policy policy-package "Standard" access true threat-prevention false targets.1 "R80dot40mgmt"
mgmt_cli --session-id \$SID install-policy policy-package "Standard" access false threat-prevention true targets.1 "R80dot40mgmt"
mgmt_cli --session-id \$SID logout
echo "Restarting API Server"
api restart
mv /home/admin/R80setup /home/admin/R80setup.old
EOT

reboot
