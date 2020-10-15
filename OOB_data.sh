echo "#############################################"
echo " The OOB log tool should be run against a node while it is still in a hung or non-responsive state "
echo " please run this script on one of CVMs which can reach BMC ip address"
echo "#############################################"
sleep 5

#you can set AHV to be hung with below setting
#[root@ahv]# echo 0 > /proc/sys/kernel/panic
#[root@ahv]# echo "kernel.panic = 0" >> /etc/sysctl.conf
#[root@ahv]# chkconfig kdump off
#[root@ahv]# service kdump stop

echo "#############################################"
echo "What is the IPMI ip address?"
echo "#############################################"
read BMC_IP

echo "#############################################"
echo "What is the IPMI admin password?"
echo "#############################################"
read BMC_PASS

echo "########################################################"
echo "Has the node rebooted already? Y or N"
echo "########################################################"
read REBOOT

if [ $REBOOT = "Y" ]
then
	echo "The node is already rebooted so Just hit Y in next question"
	echo "Pressing "Y" does not reboot the node. It will cause the script to wait 90 seconds and then perform a second collection of the IPMI SEL log"
    cd ~/tmp
    wget http://download.nutanix.com/2893%2Fcollect_oob_v3.3.tar.gz
    tar zxvf *collect*.tar.gz
    cd collect_oob
    ./collect_oob_logs.sh -i $BMC_IP -u ADMIN -p $BMC_PASS

    echo "The output file will be collected on ~/tmp/collect_oob directory with node serial number"

elif [ $REBOOT = "N" ]
then
    echo "The node hasn't been rebooted yet."
    echo "Will try to create core now"
    echo "Once the node comes back online after reboot using either option above, press "Y" and Enter so collect_oob_logs.sh can continue"
    sleep 5
    ipmitool -I lanplus -H $BMC_IP -U ADMIN -P $BMC_PASS chassis power diag

    sleep 180
    cd ~/tmp
    wget http://download.nutanix.com/2893%2Fcollect_oob_v3.3.tar.gz
    tar zxvf *collect*.tar.gz
    cd collect_oob
    ./collect_oob_logs.sh -i $BMC_IP -u ADMIN -p $BMC_PASS

    echo "The output file will be collected on ~/tmp/collect_oob directory with node serial number"

else
	echo "You selected wrong option"
fi