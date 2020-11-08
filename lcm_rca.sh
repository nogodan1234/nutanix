
echo "#############################################"
echo "Version info"
echo "#############################################"
rg -z "version:|Hypervisor:" -g "lcm_info.txt" | sort -ur

echo "#############################################"
echo "Dependency error check"
echo "#############################################"
rg -z "is not compatible with the current versions of these dependencies" -g "genesis*"

echo "#############################################"
echo "Detected valid upgrade version"
echo "#############################################"
rg -z "can be satisfied. Looking for any of the following valid versions" -g "genesis*"

echo "#############################################"
echo "Inventory result"
echo "#############################################"
rg -z "Inventory result: " -g "lcm_ops.out"

echo "#############################################"
echo " https://jira.nutanix.com/browse/ENG-332364"
echo " [LCM]BMC update to 3.64 leaves node in Phoenix and BMC will not be accessible"
echo "#############################################"
rg -z "Upgrade failed. Removing staging directory" -g "lcm_ops*"

echo "#############################################"
echo " https://jira.nutanix.com/browse/ENG-313018"
echo " LCM upgrade failed due to Foundation time out before CVM came online"
echo "#############################################"
rg -z "LCM failed performing action reboot_from_phoenix in phase PostActions on ip address" -g "genesis*"