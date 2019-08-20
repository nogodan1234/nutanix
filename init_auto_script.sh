#!/bin/bash
read -p "Please enter Prism Element cluster ip: " remotepe
echo "Your Prism Cluster IP is $remotepe "
echo "Please make sure you already installed ssh key to the cluster"
sleep 2

ssh nutanix@"$remotepe"  "bash -s" < ./auto_script.sh
