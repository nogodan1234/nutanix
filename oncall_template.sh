#!/usr/bin/bash


echo "#############################################"
echo " What is the customer name for this issue? "
echo "#############################################"
read CUSTOMER

echo "#############################################"
echo " What is the case number you want to analize? "
echo "#############################################"
read CASE_NUM

CLUSTER_ID=`ncli cluster info | grep "Cluster Id"| cut -d ':' -f4`

echo "#############################################"
echo " Is the production? YES or NO "
echo "#############################################"
read PRODUCTION

BLOCK=`ncli ru ls | grep -i "Rack Model Name" | sort -ur|cut -d ':' -f2 |xargs`
NO_NODE=`svmips | wc -w`
HYPERVISOR=`ncli ms ls | egrep "Hypervisor Type|Hypervisor Version"|sort -u |cut -d ':' -f2 | xargs`
NCC_VER=`ncc --version`
AOS_VER=`ncli cluster info | grep -i "Cluster Version" | cut -d ':' -f2`

echo "#############################################"
echo "What is the application running on the cluster? EX)VDI,EXCHANGE,CRM  "
echo "#############################################"
read APPLICATION

echo "#############################################"
echo " Is the tunnel available? YES or NO "
echo "#############################################"
read TUNNEL

echo "#############################################"
echo " What is the tunnel password if it is not default, give NA if tunnel is not enabled "
echo "#############################################"
read TUN_PASS

echo "#############################################"
echo "Is this Webex only? YES or NO "
echo "#############################################"
read WEB_AV

echo "#############################################"
echo "Is this Dark site? YES or NO "
echo "#############################################"
read DARK

echo 
echo "SFDC case: $CASE_NUM "
echo "Cluster ID: $CLUSTER_ID "
echo "Production: $PRODUCTION"
echo "Block: $BLOCK"
echo "Number of nodes: $NO_NODE"
echo "Hypervisor: $HYPERVISOR"
echo "NCC version: $NCC_VER"
echo "Application: $APPLICATION"
echo "Tunnel available: $TUNNEL"
echo "Tunnel Password: $TUN_PASS"
echo "Webex only: $WEB_AV"
echo "Dark site: $DARK"
echo "AOS Version: $AOS_VER"
echo "Customer Name: $CUSTOMER"
echo

sleep 5

echo "#############################################"
echo "Do you want to run ncc health check? Y or N "
echo "#############################################"
read NCC_RUN
if [ $NCC_RUN = "Y" ]
then
	ncc health_checks run_all
else
	exit
fi





