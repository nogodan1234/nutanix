#!/usr/bin/bash

echo "Removing files from delete safe directory "
rm -rf /home/nutanix/data/cores/*
rm -rf /home/nutanix/data/binary_logs/*
rm -rf /home/nutanix/data/ncc/installer/*
rm -rf /home/nutanix/data/log_collector/*
rm -rf /home/nutanix/foundation/tmp/*

echo "Checking Prsim service temp directory"
for i in `svmips` ; do echo "$i #####################" ; ssh -q $i du -sh /home/nutanix/prism/temp  /dev/null | head -n 2 ; done

echo "Checking for old AOS installer pkg"
CURRENT_VERSION=`ncli cluster info | grep "Cluster Version" | awk '{print $4}'`
echo "current AOS version is $CURRENT_VERSION"

NUM_OLDAOS=`ls -latr /home/nutanix/data/installer/ | grep -v $CURRENT_VERSION | grep release-euphrates | awk '{print $9}'|wc -l`
echo "$NUM_OLDAOS old AOS pkg detected"
while [ $NUM_OLDAOS -gt 0 ]  
do
        OLD_AOSVER=`ls -ltr /home/nutanix/data/installer/ | grep -v $CURRENT_VERSION | grep release-euphrates | awk '{print $9}'`
        echo "Removing Old AOS version"
        rm -rf /home/nutanix/data/installer/$OLD_AOSVER
        NUM_OLDAOS=$[$NUM_OLDAOS-1]
done

#checking for NCC 3.7.0 bug
echo "Checking for NCC bug ENG-220802(big big ncc_log_collector.log) "
for i in `svmips` ; do echo "$i #################" ; ssh -q $i ls -lSh ~/data/logs/ncc*.log  /dev/null | head -n 2 ; done

echo "Listing +100M file under /home/nutanix/foundation/isos/ "
find /home/nutanix/foundation/isos/ -type f -size +100M -exec ls -l {} \;
#find /home/nutanix/foundation/isos/ -type f -size +100M -exec rm {} \;
echo "Please check to see if any file can be deleted"
sleep 15

echo "Older than 4 day log files under ~/data/logs/"
find /home/nutanix/data/logs -type f -mtime +4 -exec ls -l {} \;
#find /home/nutanix/data/logs -type f -mtime +4 -exec rm {} \;
echo "Please check to see if any file can be deleted"
sleep 15
