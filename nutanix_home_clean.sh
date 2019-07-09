#!/usr/bin/bash

echo "Removing files from safe directory to delete"
rm -rf /home/nutanix/data/cores/*
rm -rf /home/nutanix/data/binary_logs/*
rm -rf /home/nutanix/data/ncc/installer/*
rm -rf /home/nutanix/data/log_collector/*
rm -rf /home/nutanix/foundation/tmp/*

echo "Listing foundation image iso from /home/nutanix/foundation/isos/ "
find /home/nutanix/foundation/isos/ -type f -size +100M -exec ls -l {} \;
#find /home/nutanix/foundation/isos/ -type f -size +100M -exec rm {} \;
echo "Please check to see if any file can be deleted"
sleep 15 

echo "Older than 4 day log files from ~/data/logs/"
find /home/nutanix/data/logs -type f -mtime +4 -exec ls -l {} \;
#find /home/nutanix/data/logs -type f -mtime +4 -exec rm {} \;
echo "Please check to see if any file can be deleted"
sleep 15

echo "Checking Prsim service temp directory"
allssh "du -sh /home/nutanix/prism/temp"

echo "Checking for old AOS install pkg"
CURRENT_VERSION=`ncli cluster info | grep "Cluster Version" | awk '{print $4}'`
echo "current AOS version is $CURRENT_VERSION"
ls -latr /home/nutanix/data/installer/ | grep -v $CURRENT_VERSION | grep release | awk '{print $9}'
OLD_AOSVER=`ls -latr /home/nutanix/data/installer/ | grep -v $CURRENT_VERSION | grep release | awk '{print $9}'`
echo "Old AOS pkg $OLD_AOSVER is detected"

echo "Removing Old AOS version"
rm -rf /home/nutanix/data/installer/$OLD_AOSVER

#checking for NCC 3.7.0 bug
echo "Checking for NCC bug ENG-220802(big big ncc_log_collector.log) "
allssh "ls -lSh ~/data/logs/ncc*.log | head -n 2"