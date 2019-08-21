#!/usr/bin/bash

# Disclaimer: Usage of this tool must be under guidance of Nutanix Support or an authorised partner
# Summary: This is clean up script for nutanix home directory - http://portal.nutanix.com/kb/1540
# Version of the script: Version 1
# Compatible software version(s): ALL AOS version
# Brief syntax usage: nutanix$sh nutanix_home_clean.sh
# Caveats: This script does not delete old log files under ~/data/logs and +100M file under /home/nutanix/foundation/isos/, only displays them

tar xvf *.tar
rm *.tar
LOGSET=`ls -al | grep -v tar | grep -i ncc | awk '{print $9}'`
cd $LOGSET
for i in $(ls -l  | grep gz | awk -F" " '{print $9}'); do tar xvf $i ;done
rm *.gz

echo "#############################################"
echo " Network Status Check "
echo "#############################################"
find . -name ping_hosts.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" |tail -50 > ~/tmp/ping_hosts.txt
find . -name ping_gateway.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" |tail -50 > ~/tmp/ping_gw.txt
find . -name ping_cvm_hosts.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" |tail -50 > ~/tmp/ping_cvm.txt
sleep 2

echo "#############################################"
echo " AOS Version check"
echo "#############################################"
 find . -name release_* -exec cat {} \; > ~/tmp/AOS_ver.txt
sleep 2

echo "#############################################"
echo " Hypervisor Version check"
echo "#############################################"
 find . -name sysctl_info.txt > ~/tmp/hyper_ver.txt
 find . -name sysctl_info.txt -exec cat {} \; | grep release  >> ~/tmp/hyper_ver.txt
sleep 2

echo "#############################################"
echo " Log collector run time"
echo "#############################################"
 find . -name sysctl_info.txt -exec head -1 {} \; > ~/tmp/ncc_run_time.txt
sleep 2

echo "#############################################"
echo " Cluster ID"
echo "#############################################"
 ls | grep NCC | cut -d '-' -f 6 > ~/tmp/cluster_id.txt
sleep 2

echo "#############################################"
echo " Hard Ware Model Check"
echo "#############################################"
 rg "Product Part Number" . | grep hardware_logs > ~/tmp/HW.txt
sleep 2

echo "#############################################"
echo " BMC/BIOS version"
echo "#############################################"
 find . -name hardware_info -exec grep -w -A 6 -e Info -e BIOS -e bmc {} \;> ~/tmp/BMC_BIOS.txt
sleep 2

echo "#############################################"
echo " ESXi hypervisor network error check "
echo "#############################################"
rg -z "Network unreachable" . > ~/tmp/esxi.network.err.txt
sleep 2

echo "#############################################"
echo "1. ENG-177414 - Cassandra Too many SSTables "
echo "#############################################"
sleep 2
rg -z -B 1 -A 1 "Too many SSTables found for Keyspace : medusa" .

#rg -z -B 1 -A 1 "Stargate on node" . | rg "is down" .
echo "#############################################"
echo "2. ISB-101-2019: Increasing the CVM Common Memory Pool "
echo "#############################################"
sleep 2
rg -z -B 1 -A 1 "Out of memory: Kill process" . | egrep -i "ServiceVM_Centos.0.out|NTNX.serial.out.0"


echo "#############################################"
echo "3. ENG-218803 , ISB-096-2019 Corrupt sstables"
echo "#############################################"

sleep 2
rg -z -B 1 -A 1 "Corrupt sstables" .
rg -z -B 1 -A 1 "kCorruptSSTable" .
rg -z -B 1 -A 1 "java.lang.AssertionError" .

echo "#############################################"
echo "4. Stargate health check"
echo "#############################################"
sleep 2
rg -z "Couldn't lookup metadata for extent group" .
rg -z "kUnexpectedIntentSequence" .
rg -z "Inserted HA route on host" .
rg -z "Stargate exited" .
rg -z "QFATAL Timed out waiting for Zookeeper session establishment" .

echo "#############################################"
echo "5. Token revoke failure"
echo "#############################################"
sleep 2
rg -z "Failed to revoke token from" .

echo "#############################################"
echo "6. scsi controller timeout"
echo "#############################################"
sleep 2
rg -z "mpt3sas_cm0: Command Timeout" .

echo "#############################################"
echo "7. Cassandra Check"
echo "#############################################"
sleep 2
rg -z "Could not start repair on the node" .
rg -z "Attempting repair of local node due to health warning" .

echo "#############################################"
echo "8. Hades Disk service check"
echo "#############################################"
sleep 2
rg -z "Failed to start DiskService. Fix the problem and start again" .
