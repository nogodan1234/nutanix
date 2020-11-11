#!/usr/bin/bash
#This is for checking bios firmware version
#28 May 2020 taeho.choi@nutanix.com
# 

echo "########################################################"
echo " What is the hypervisor type? 1.AHV 2.ESXi 3.Hyper-V "
echo "########################################################"
read HYPERVISOR

if [ $HYPERVISOR = "1" ]
then
	echo "You selected AHV ... checking the detail.."
	echo "########################################################"
	echo "HW Model is  "
	echo "########################################################"
	#ncli host  ls | egrep "Controller VM Address|Block Serial" | awk '{print $5,$6}'
	for i in `hostips` ; do echo "==== $i ====" ; ssh -q root@$i 'dmidecode | grep "Product Name" '| head -1 ;done
	echo "########################################################"
	echo "BMC version is "
	echo "########################################################"
	for i in `hostips` ; do echo "==== $i ====" ; ssh -q root@$i "ipmitool mc info| grep 'Firmware Revision'"|cut -d ' ' -f12 ;done
	echo "########################################################"
	echo "BIOS version is"
	echo "########################################################"
	for i in `hostips` ; do echo "==== $i ====" ; ssh -q root@$i "dmidecode | grep 'Version: '" | head -1 | cut -d ' ' -f2 ;done

elif [ $HYPERVISOR = "2" ]
then
	echo "You selected ESXi ... checking the detail.."
	echo "########################################################"
	echo "HW Model is  "
	echo "########################################################"
	#ncli host  ls | egrep "Controller VM Address|Block Serial" | awk '{print $5,$6}'
	for i in `hostips` ; do echo "==== $i ====" ; ssh -q root@$i  smbiosDump | grep -i product| head -1 | awk -F' ' '{print $2}'; done
	echo "########################################################"
	echo "BMC version is "
	echo "########################################################"
	for i in `hostips` ; do echo "==== $i ====" ; ssh -q root@$i "/ipmitool bmc info| grep -i firmware "|cut -d ' ' -f12  ;done
	echo "########################################################"	
	echo "BIOS version is"
	echo "########################################################"
	for i in `hostips` ; do echo "==== $i ====" ; ssh -q root@$i "smbiosDump  | grep Version | head -1" | cut -d ' ' -f6 ;done

elif [ $HYPERVISOR = "3" ]
then
	echo "You selected Hyper-V ... checking the detail.."
	echo "########################################################"
	echo "HW Model is  "
	echo "########################################################"
	#ncli host  ls | egrep "Controller VM Address|Block Serial" | awk '{print $5,$6}'
	hostssh 'systeminfo| grep "System Model" '
	echo "########################################################"	
	echo "BMC version is "
	echo "########################################################"
	hostssh date
	hostssh 'ipmiutil sel -v | grep BMC ' | cut -d ' ' -f4
	echo "########################################################"	
	echo "BIOS version is"
	echo "########################################################"
	hostssh 'systeminfo | grep BIOS' | awk '{print $6}'
else
	echo "You selected wrong option"
fi

#BMC version
#ncli host ls | grep "IPMI Address" | awk -F: '{print $2}' | while read LINE ; do echo IPMI address $LINE ; ipmitool -I lanplus -H $LINE -U ADMIN -P ADMIN  bmc info | grep "Firmware Revision" ; done