#!/usr/bin/bash

# Disclaimer: Usage of this tool must be used only on nutanix diamond platform
# You can review source code from https://github.com/nogodan1234/nutanix/blob/master/taeho_rca.sh
# Downloadable from diamond : curl -OL https://raw.githubusercontent.com/nogodan1234/nutanix/master/taeho_rca.sh
# Version of the script: Version 1
# Compatible software version(s): ALL AOS version - ncc/logbay logset
# Brief syntax usage: diamond$sh taeho_rca.sh


echo "#############################################"
echo " What is the case number you want to analize? "
echo " Log will be extracted on ~/shared/$CASE_NUM "
echo "#############################################"
read CASE_NUM

echo "#############################################"
echo " Removing existing directory for the case if exists "
echo " rm -rf ~/shared/$CASE_NUM "
echo "#############################################"
rm -rf ~/shared/$CASE_NUM

echo "#############################################"
echo " Extracting log bundle from ncc/logbay "
echo "#############################################"
carbon extract $CASE_NUM
#carbon logbay $CASE_NUM
cd ~/shared/$CASE_NUM
cd *PE

#echo "#############################################"
#echo " Extracting log bundle from logbay "
#echo "#############################################"
#unzip *.zip
#rm *.zip
#LOGSET2=`ls -al | grep -i NTNX| awk '{print $9}'`
#cd $LOGSET2
#for i in $(ls -l  | grep zip | awk -F" " '{print $9}'); do unzip $i ;done
#rm *.zip

echo "#############################################"
echo " Network Status Check "
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
find . -name ping_hosts.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" > ~/tmp/ping_hosts.txt
find . -name ping_gateway.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" > ~/tmp/ping_gw.txt
find . -name ping_cvm_hosts.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" > ~/tmp/ping_cvm.txt
sleep 2

echo "#############################################"
echo " AOS Version check"
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
 rg -z "release" -g release_version > ~/tmp/AOS_ver.txt
sleep 2

echo "#############################################"
echo " Hypervisor Version check"
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
 rg -z "release" -g sysctl_info.txt > ~/tmp/hyper_ver.txt
sleep 2

echo "#############################################"
echo " Log collector run time"
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
rg -z "Log Collector Start time" -g sysctl_info.txt > ~/tmp/ncc_run_time.txt
sleep 2

echo "#############################################"
echo " Cluster ID"
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
rg -z -B1 "cluster_name" -g "zeus_config.*" . | sort -u > ~/tmp/cluster_id.txt
sleep 2

echo "#############################################"
echo " Upgrade history"
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
rg -z release -g "upgrade.history" > ~/tmp/upgrade_history.txt
sleep 2

echo "#############################################"
echo " Hardware Model Check"
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
 rg -z "FRU Device Description" -A14 -g "hardware_info" > ~/tmp/HW.txt
sleep 2

echo "#############################################"
echo " BMC/BIOS version"
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
 rg -z "bmc info" -A5 -g "hardware_info" > ~/tmp/bmc_ver.txt
 rg -z "BIOS Information" -A2 -g "hardware_info" > ~/tmp/bios_ver.txt
sleep 2

echo "#############################################"
echo " ESXi hypervisor network error check "
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
rg -z "Network unreachable" . > ~/tmp/esxi.network.err.txt
sleep 2

echo "#############################################" 					
echo "CVM/hypervisor reboot check " 								
echo "#############################################" 					
sleep 2
rg -z "system boot" -g "config.txt" > ~/tmp/cvm_reboot.txt
rg -z "system boot" -g "kvm_info.txt" > ~/tmp/ahv_reboot.txt				

echo "#############################################"
echo " NCC version check "
echo " Output file will be generated in ~/tmp folder"
echo "#############################################"
rg -z "Ncc Version number" -g "log_collector.out*" > ~/tmp/NCC_Ver.txt
sleep 2

echo "#############################################"  					
echo " Disk failure check"     						  					
echo "#############################################"  					
rg "attempting task abort! scmd" . 										
sleep 2

echo "#############################################"  					
echo "1. ENG-177414 - Cassandra Too many SSTables "  					
echo "#############################################"  					
sleep 2
rg -z -B 1 -A 1 "Too many SSTables found for Keyspace : medusa" -g "cassandra*"		
sleep 2

echo "#############################################"  					
echo "FA67 Metadata corruption due to skipped row"  					
echo "#############################################" 
rg -z -B 1 -A 1 "Skipping row DecoratedKey" . 							

echo "#############################################"  					
echo "ONCALL-8062 fix in 5.10.9 Wrong CVM became degraded "  			
echo "#############################################" 
rg -z "notification=NodeDegraded service_vm_id=" . 						

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
rg -z "Corruption fixer op finished with errorkDataCorrupt on egroup" .
rg -z "kUnexpectedIntentSequence" . 									
rg -z "Inserted HA route on host" . 									
rg -z "Stargate exited" . 												
rg -z "QFATAL Timed out waiting for Zookeeper session establishment" . 	
rg -z "Becoming NFS namespace master" . 								
rg -z "Hosting of virtual IP " . 										
#rg -z "nfs_remove_op.cc" . 												
rg -z "Created iSCSI session for leading connection" . 					
rg -z "SMB-SESSION-SETUP request got for connection" . 					
#echo "ENG-30397 ext4 file corruption" 									
#rg -z "kSliceChecksumMismatch" . 										
echo "Checking ... Disk IO ms check > 100ms" 										
find . -name stargate.INFO* -exec grep "AIO disk" {} \; 				
rg -z "Starting Stargate" . 											
rg -z "Becoming NFS namespace master" . 								
#rg -z "Requested deletion of egroup" . 									
rg -z "completed with error kRetry for vdisk" . 						
echo "Checking ... SSD tier running out of space" 										
rg -z "Unable to pick a suitable replica" . 							
echo "Checking ... Unfixable egroup corruption" 										
rg -z "are either unavailable or corrupt" . 							
echo "NFS server requested client to retry" 							
rg -z "Checking ... NFS3ERR_JUKEBOX error" . 												
echo "Checking ... Oplog corrupt detection" 											
rg -z "is missing on all the replicas" . 								
echo "Checking ... RSS memory dump/crash" 													
rg -z "Exceeded resident memory limit: Aborting" . 						
echo "Checking ... Stargate FATAL"
rg '^F[0-9]{4}' -g 'stargate*'											

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
#rg -z "Attempting repair of local node due to health warning" . 		
rg -z "as degraded after analyzing" . 									
echo "# ENG-149005,ENG-230635 Heap Memory issue #" 						
rg -z "Paxos Leader Writer timeout waiting for replica leader" . 		
echo "# ISB-102-2019 #" 												
#https://confluence.eng.nutanix.com:8443/display/STK/ISB-102-2019%3A+Data+inconsistency+on+2-node+clusters
rg -z "has been found dead" . 											
rg -z "does not exist when extent oid=" . 								
rg -z "Leadership acquired for token:" . 								
rg -z "RegisterForLeadership for token:" . 								
rg -z "with transformation type kCompressionLZ4 and transformed length" . 
#rg -z "Failing GetEgroupStateOp as the extent group does not exist on disk" . 
echo "Cassandra heap memory congestion check" 							
rg -z "GCInspector.java" -g "system.log*"									
echo "# Cassandra restart" 												
rg -z "Logging initialized" -g "system.log*" 				

echo "#############################################" 					
echo "8. Hades Disk service check" 					 					
echo "#############################################" 					
sleep 2
rg -z "Failed to start DiskService. Fix the problem and start again" -g "hades*"
rg -z "is not in disk inventory"  -g "hades*"									

echo "#############################################" 					
echo "9. Curator Scan Failure due to network issue"  					
echo "#############################################" 					
sleep 2
rg -z "Http request timed out" -g "curator.*"	

echo "#############################################" 					
echo "10. Acropolis service crash" 					 					
echo "#############################################" 					
sleep 2
rg -z "Acquired master leadership" .									
rg -z "Failed to re-register with Pithos after 60 seconds" . 			
rg -z "Time to fire reconcilliation callback took" -g "acropolis.out*"				

echo "#############################################" 					
echo "11. Pithos service crash - ENG-137628" 		 					
echo "#############################################" 					
sleep 2
rg -z "GetRangeSlices RPC failed (kTimeout: TimedOutException())" . 	

echo "#############################################"   					
echo "12. File Descriptior Check - KB 3857 ENG-119268" 					
echo "#############################################"   					
sleep 2
rg -z "Resource temporarily unavailable" . 			   					
rg -z "[ssh] <defunct>" . | wc -l 					   					

echo "#############################################"   					
echo "13. Stargate crashing due to AHV frodo service failure ONCALL-7326" 
echo "#############################################"   					
sleep 2
rg -z "Check failed: count_ == write_iobuf_->size()" . 					

echo "#############################################"   					
echo "14. Pithos vdisk update failure  ONCALL-7326 ENG-238450" 			
echo "maybe good to check with pithos_cli -exhaustive_validate" 		
echo "#############################################"   					
sleep 2
rg -z "Failed to modify and update all the given vdisks, only 0 were successfully updated" . 
rg -z "Not performing selective vdisk severing as no vdisks are selected for copy blockmap" . 

echo "#############################################" 					
echo "15. Missing egroup replica check ONCALL-4514" 					
echo  "need to confirm with medusa_printer and egroup_collector.py " 	
echo "#############################################" 					
sleep 2
rg -z "changed from 1 to 0 due to egroup" -g "curator.*"
# Run egroup_collector.py from diamond server
echo "/users/eng/tools/egroup_corruption/egroup_collector.py --egroup_id $EID --output dir /users/taeho.choi/tmp" 
echo "medusa_printer --lookup=egid --egroup_id=$EID" 					

echo "#############################################" 					
echo "16. Failed disk check from hades log" 							
echo "#############################################" 					
sleep 2
rg -z "Handling hot-remove event for disk" -g "hades.out*"

echo "#############################################" 					
echo "17. Disk forcefully was pulled off " 								
echo "#############################################" 					
sleep 2
rg -z "is not marked for removal and has been forcefully pulled" . 		
#disk_operator accept_old_disk $DISK_SN

echo "#############################################" 					
echo "18. iscsi connection reset " 										
echo "#############################################" 					
sleep 2
rg -z "Removing initiator iqn" -g "stargate*"										

echo "#############################################" 					
echo "19. HBA reset reset " 											
echo "#############################################" 					
sleep 2
rg -z "sending diag reset" . 											

echo "#############################################" 					
echo "20. Cerebro bug ENG-247313 " 										
echo "#############################################" 					
sleep 2
rg -z "Cannot reincarnate a previously detached entity without an incarnation_id" . 	

echo "#############################################" 					
echo "21. FATAL log check $filter ." 											
echo "#############################################" 					
sleep 2
#filter=F`(date '+%m%d')`
#rg -z $filter .	
