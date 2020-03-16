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
rm -rf ~/tmp/$CASE_NUM
mkdir ~/tmp/$CASE_NUM

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
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
find . -name ping_hosts.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" > ~/tmp/$CASE_NUM/ping_hosts.txt
find . -name ping_gateway.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" > ~/tmp/$CASE_NUM/ping_gw.txt
find . -name ping_cvm_hosts.INFO* -exec cat {} \; | egrep -v "IP : time" | awk '/^#TIMESTAMP/ || $3>13.00 || $3=unreachable' | egrep -B1 " ms|unreachable" | egrep -v "\-\-" > ~/tmp/$CASE_NUM/ping_cvm.txt
sleep 2

echo "#############################################"
echo " AOS Version check"
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
 rg -z "release" -g release_version 															> ~/tmp/$CASE_NUM/AOS_ver.txt
sleep 2

echo "#############################################"
echo " Hypervisor Version check"
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
 rg -z "release" -g sysctl_info.txt 															> ~/tmp/$CASE_NUM/hyper_ver.txt
sleep 2

echo "#############################################"
echo " Log collector run time"
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
rg -z "Log Collector Start time" -g sysctl_info.txt 											> ~/tmp/$CASE_NUM/ncc_run_time.txt
sleep 2

echo "#############################################"
echo " Cluster ID"
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
rg -z -B1 "cluster_name" -g "zeus_config.*"| sort -u 											> ~/tmp/$CASE_NUM/cluster_id.txt
sleep 2

echo "#############################################"
echo " Upgrade history"
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
rg -z release -g "upgrade.history" 																> ~/tmp/$CASE_NUM/upgrade_history.txt
sleep 2

echo "#############################################"
echo " Hardware Model Check"
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
 rg -z "FRU Device Description" -A14 -g "hardware_info" 										> ~/tmp/$CASE_NUM/HW.txt
sleep 2

echo "#############################################"
echo " BMC/BIOS version"
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
 rg -z "bmc info" -A5 -g "hardware_info" 														> ~/tmp/$CASE_NUM/bmc_ver.txt
 rg -z "BIOS Information" -A2 -g "hardware_info" 												> ~/tmp/$CASE_NUM/bios_ver.txt
sleep 2

echo "#############################################"
echo " Hypervisor network error check "
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
rg -z "Network unreachable"																		> ~/tmp/$CASE_NUM/esxi.network.err.txt
rg -z "NIC Link is Down" -g "vmkernel.*" 														> ~/tmp/$CASE_NUM/hyper_network.err.txt
rg -z "NIC Link is Down" -g "message*" 															>> ~/tmp/$CASE_NUM/hyper_network.err.txt
rg -z "NIC Link is Down" -g "dmesg*" 															>> ~/tmp/$CASE_NUM/hyper_network.err.txt
sleep 2

echo "#############################################" 					
echo "CVM/hypervisor reboot check "
echo " Output file will be generated in ~/tmp/$CASE_NUM folder" 								
echo "#############################################" 					
sleep 2
rg -z "system boot" -g "config.txt" 															> ~/tmp/$CASE_NUM/cvm_reboot.txt
rg -z "system boot" -g "kvm_info.txt" 															> ~/tmp/$CASE_NUM/ahv_reboot.txt				

echo "#############################################"
echo " NCC version check "
echo " Output file will be generated in ~/tmp/$CASE_NUM folder"
echo "#############################################"
rg -z "Ncc Version number" -g "log_collector.out*" 												> ~/tmp/$CASE_NUM/NCC_Ver.txt
sleep 2

echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/Disk_failure.txt
echo " Disk failure check"     						  											| tee -a ~/tmp/$CASE_NUM/Disk_failure.txt	
echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/Disk_failure.txt
rg "attempting task abort! scmd"																| tee -a ~/tmp/$CASE_NUM/Disk_failure.txt									
sleep 2

echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/Cass_Too_many_SStables-ENG-177414.txt	
echo "1. ENG-177414 - Cassandra Too many SSTables "  											| tee -a ~/tmp/$CASE_NUM/Cass_Too_many_SStables-ENG-177414.txt	
echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/Cass_Too_many_SStables-ENG-177414.txt	
sleep 2
rg -z -B 1 -A 1 "Too many SSTables found for Keyspace : medusa" -g "cassandra*" 				| tee -a ~/tmp/$CASE_NUM/Cass_Too_many_SStables-ENG-177414.txt			
sleep 2

echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/FA67metadata_corrupt.txt
echo "FA67 Metadata corruption due to skipped row"  											| tee -a ~/tmp/$CASE_NUM/FA67metadata_corrupt.txt
echo "#############################################" 											| tee -a ~/tmp/$CASE_NUM/FA67metadata_corrupt.txt
rg -z -B 1 -A 1 "Skipping row DecoratedKey"  													| tee -a ~/tmp/$CASE_NUM/FA67metadata_corrupt.txt							

echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/node_degraded.txt
echo "ONCALL-8062 fix in 5.10.9 Wrong CVM became degraded "  									| tee -a ~/tmp/$CASE_NUM/node_degraded.txt
echo "#############################################" 											| tee -a ~/tmp/$CASE_NUM/node_degraded.txt
rg -z "notification=NodeDegraded service_vm_id="												| tee -a ~/tmp/$CASE_NUM/node_degraded.txt

#rg -z -B 1 -A 1 "Stargate on node"| rg "is down" .
echo "#############################################"  												| tee -a ~/tmp/$CASE_NUM/OOM.txt	
echo "2. ISB-101-2019: Increasing the CVM Common Memory Pool "  									| tee -a ~/tmp/$CASE_NUM/OOM.txt		
echo "#############################################"  												| tee -a ~/tmp/$CASE_NUM/OOM.txt		
sleep 2
rg -z -B 1 -A 1 "Out of memory: Kill process"| egrep -i "ServiceVM_Centos.0.out|NTNX.serial.out.0"  | tee -a ~/tmp/$CASE_NUM/OOM.txt	

echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/Cass_Corrupt_table.txt		
echo "3. ENG-218803 , ISB-096-2019 Corrupt sstables"  											| tee -a ~/tmp/$CASE_NUM/Cass_Corrupt_table.txt		
echo "#############################################"  											| tee -a ~/tmp/$CASE_NUM/Cass_Corrupt_table.txt		
sleep 2
rg -z -B 1 -A 1 "Corrupt sstables" -g "cassandra*"												| tee -a ~/tmp/$CASE_NUM/Cass_Corrupt_table.txt									
rg -z -B 1 -A 1 "kCorruptSSTable" -g "cassandra*" 												| tee -a ~/tmp/$CASE_NUM/Cass_Corrupt_table.txt								
rg -z -B 1 -A 1 "java.lang.AssertionError" -g "cassandra*" 										| tee -a ~/tmp/$CASE_NUM/Cass_Corrupt_table.txt							

echo "#############################################"  											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt	
echo "4. Stargate health check"						  											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
echo "#############################################"  											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
sleep 2
rg -z "Corruption fixer op finished with errorkDataCorrupt on egroup" 							| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
rg -z "kUnexpectedIntentSequence" 					 											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
rg -z "Inserted HA route on host" -g "genesis*"		 											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt							
rg -z "Stargate exited" -g "stargate*"				 											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt								
rg -z "QFATAL Timed out waiting for Zookeeper session establishment" -g "stargate*" 			| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt	
rg -z "Becoming NFS namespace master" 				 											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt								
rg -z "Hosting of virtual IP " 						 											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt 										
#rg -z "nfs_remove_op.cc"												
rg -z "Created iSCSI session for leading connection" 											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt 					
rg -z "SMB-SESSION-SETUP request got for connection" 											| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt 					
#echo "ENG-30397 ext4 file corruption" 									
#rg -z "kSliceChecksumMismatch"										
echo "Checking ... Disk IO ms check > 100ms"													| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
rg -z "AIO disk" -g "stargate.INFO*" 															| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt														
rg -z "Starting Stargate"   		 															| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt									
rg -z "Becoming NFS namespace master"   														| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt								
#rg -z "Requested deletion of egroup"									
rg -z "completed with error kRetry for vdisk"													| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt					
echo "Checking ... SSD tier running out of space" 												| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt									
rg -z "Unable to pick a suitable replica"														| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt					
echo "Checking ... Unfixable egroup corruption" 												| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt									
rg -z "are either unavailable or corrupt"														| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt					
echo "NFS server requested client to retry" 													| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt					
rg -z "Checking ... NFS3ERR_JUKEBOX error"														| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt										
echo "Checking ... Oplog corrupt detection" 													| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt									
rg -z "is missing on all the replicas"															| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt					
echo "Checking ... RSS memory dump/crash" 														| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt										
rg -z "Exceeded resident memory limit: Aborting"												| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
echo "Run out of storage space" 																| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
rg -z "failed with error kDiskSpaceUnavailable" -g "stargate.INFO*" 							| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt																			
echo "Checking ... Stargate FATAL"																| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt
rg '^F[0-9]{4}' -g 'stargate*'	  																| tee  -a ~/tmp/$CASE_NUM/Stargate_health.txt										

echo "#############################################"  											| tee   -a ~/tmp/$CASE_NUM/revoke_token.txt				
echo "5. Token revoke failure" 						  											| tee   -a ~/tmp/$CASE_NUM/revoke_token.txt				
echo "#############################################" 											| tee   -a ~/tmp/$CASE_NUM/revoke_token.txt			
sleep 2
rg -z "Failed to revoke token from"																| tee   -a ~/tmp/$CASE_NUM/revoke_token.txt								

echo "#############################################" 											| tee   -a ~/tmp/$CASE_NUM/scsi_controller.txt				
echo "6. scsi controller timeout" 					 											| tee   -a ~/tmp/$CASE_NUM/scsi_controller.txt				
echo "#############################################" 											| tee   -a ~/tmp/$CASE_NUM/scsi_controller.txt					
sleep 2
rg -z "mpt3sas_cm0: Command Timeout"															| tee   -a ~/tmp/$CASE_NUM/scsi_controller.txt							

echo "#############################################" 											| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt			
echo "7. Cassandra Check" 							 											| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt	
echo "#############################################" 											| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt	
sleep 2
rg -z "Could not start repair on the node"														| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt				
#rg -z "Attempting repair of local node due to health warning"		
rg -z "as degraded after analyzing"																| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt						
echo "# ENG-149005,ENG-230635 Heap Memory issue #" 												| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt						
rg -z "Paxos Leader Writer timeout waiting for replica leader" -g "system.log*" | grep -v vdiskblockmap 	| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt		
echo "# ISB-102-2019 #" 																		| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt						
#https://confluence.eng.nutanix.com:8443/display/STK/ISB-102-2019%3A+Data+inconsistency+on+2-node+clusters
rg -z "has been found dead"																		| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt					
rg -z "does not exist when extent oid="															| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt					
rg -z "Leadership acquired for token:" -g "cassandra_monitor*"	 								| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt								
rg -z "RegisterForLeadership for token:" -g "cassandra_monitor*" 								| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt									
rg -z "with transformation type kCompressionLZ4 and transformed length" 						| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt	
#rg -z "Failing GetEgroupStateOp as the extent group does not exist on disk"
echo "Cassandra heap memory congestion check" 													| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt							
rg -z "GCInspector.java" -g "system.log*"														| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt								
echo "# Cassandra restart" 																		| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt							
rg -z "Logging initialized" -g "system.log*" 													| tee   -a ~/tmp/$CASE_NUM/cassandra_check.txt				

echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/Hades_disksvc_error.txt	
echo "8. Hades Disk service check" 					 											| tee  -a ~/tmp/$CASE_NUM/Hades_disksvc_error.txt	
echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/Hades_disksvc_error.txt	
sleep 2
rg -z "Failed to start DiskService. Fix the problem and start again" -g "hades*" 				| tee  -a ~/tmp/$CASE_NUM/Hades_disksvc_error.txt	
rg -z "is not in disk inventory"  -g "hades*"									 				| tee  -a ~/tmp/$CASE_NUM/Hades_disksvc_error.txt	

echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/curator_scan_failure.txt				
echo "9. Curator Scan Failure due to network issue"  											| tee  -a ~/tmp/$CASE_NUM/curator_scan_failure.txt				
echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/curator_scan_failure.txt				
sleep 2
rg -z "Http request timed out" -g "curator.*"													| tee  -a ~/tmp/$CASE_NUM/curator_scan_failure.txt	

echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/acropolis_check.txt				
echo "10. Acropolis service crash" 					 											| tee  -a ~/tmp/$CASE_NUM/acropolis_check.txt				
echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/acropolis_check.txt				
sleep 2
rg -z "Acquired master leadership" .															| tee  -a ~/tmp/$CASE_NUM/acropolis_check.txt				
rg -z "Failed to re-register with Pithos after 60 seconds"										| tee  -a ~/tmp/$CASE_NUM/acropolis_check.txt			
rg -z "Time to fire reconcilliation callback took" -g "acropolis.out*" 							| tee  -a ~/tmp/$CASE_NUM/acropolis_check.txt
echo "VM Delete log" 																			| tee  ~/tmp/$CASE_NUM/VM_delete.txt	
sleep 2
rg -z "notification=VmDeleteAudit"	-g "acropolis.out*"											| tee  -a ~/tmp/$CASE_NUM/VM_delete.txt	

echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/pithos_svc_crash.txt				
echo "11. Pithos service crash - ENG-137628" 		 											| tee  -a ~/tmp/$CASE_NUM/pithos_svc_crash.txt				
echo "#############################################" 											| tee  -a ~/tmp/$CASE_NUM/pithos_svc_crash.txt			
sleep 2
rg -z "GetRangeSlices RPC failed (kTimeout: TimedOutException())" 								| tee  -a ~/tmp/$CASE_NUM/pithos_svc_crash.txt	

echo "#############################################"   											| tee  -a ~/tmp/$CASE_NUM/file_desc.txt			
echo "12. File Descriptior Check - KB 3857 ENG-119268" 											| tee  -a ~/tmp/$CASE_NUM/file_desc.txt				
echo "#############################################"   											| tee  -a ~/tmp/$CASE_NUM/file_desc.txt				
sleep 2
rg -z "Resource temporarily unavailable"			   											| tee  -a ~/tmp/$CASE_NUM/file_desc.txt				
rg -z "[ssh] <defunct>"| wc -l 					   												| tee  -a ~/tmp/$CASE_NUM/file_desc.txt			

echo "#############################################"   											| tee  -a ~/tmp/$CASE_NUM/frodo_svc_crash.txt
echo "13. Stargate crashing due to AHV frodo service failure ONCALL-7326" 						| tee  -a ~/tmp/$CASE_NUM/frodo_svc_crash.txt	
echo "#############################################"   											| tee  -a ~/tmp/$CASE_NUM/frodo_svc_crash.txt
sleep 2
rg -z "Check failed: count_ == write_iobuf_->size()"					 						| tee  -a ~/tmp/$CASE_NUM/frodo_svc_crash.txt	

echo "#############################################"   					  						| tee  -a ~/tmp/$CASE_NUM/pithos_vdisk_update_failure.txt	
echo "14. Pithos vdisk update failure  ONCALL-7326 ENG-238450" 			  						| tee  -a ~/tmp/$CASE_NUM/pithos_vdisk_update_failure.txt	
echo "maybe good to check with pithos_cli -exhaustive_validate" 		  						| tee  -a ~/tmp/$CASE_NUM/pithos_vdisk_update_failure.txt	
echo "#############################################"   					  						| tee  -a ~/tmp/$CASE_NUM/pithos_vdisk_update_failure.txt	
sleep 2
rg -z "Failed to modify and update all the given vdisks, only 0 were successfully updated"  	| tee  -a ~/tmp/$CASE_NUM/pithos_vdisk_update_failure.txt	
rg -z "Not performing selective vdisk severing as no vdisks are selected for copy blockmap" 	| tee  -a ~/tmp/$CASE_NUM/pithos_vdisk_update_failure.txt	

echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/missing_egroup_replica.txt	
echo "15. Missing egroup replica check ONCALL-4514" 					  						| tee  -a ~/tmp/$CASE_NUM/missing_egroup_replica.txt	
echo  "need to confirm with medusa_printer and egroup_collector.py " 	  						| tee  -a ~/tmp/$CASE_NUM/missing_egroup_replica.txt	
echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/missing_egroup_replica.txt	
sleep 2
rg -z "changed from 1 to 0 due to egroup" -g "curator.*"                  						| tee  -a ~/tmp/$CASE_NUM/missing_egroup_replica.txt	
# Run egroup_collector.py from diamond server
echo "/users/eng/tools/egroup_corruption/egroup_collector.py --egroup_id $EID --output dir /users/taeho.choi/tmp" | tee  -a ~/tmp/$CASE_NUM/missing_egroup_replica.txt	
echo "medusa_printer --lookup=egid --egroup_id=$EID" 					  						| tee  -a ~/tmp/$CASE_NUM/missing_egroup_replica.txt	

echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt	
echo "16. Check disk operation from hades log" 							  						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt	
echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt	
sleep 2
rg -z "Handling hot-remove event for disk" -g "hades.out*"                						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt    
rg -z "Handling hot-plug" -g "hades.out*"                                 						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt

echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt
echo "17. Disk forcefully was pulled off " 								  						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt
echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt
sleep 2
rg -z "is not marked for removal and has been forcefully pulled"		  						| tee  -a ~/tmp/$CASE_NUM/physical_disk_op.txt
#disk_operator accept_old_disk $DISK_SN

echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/iscsi_reset.txt
echo "18. iscsi connection reset " 										  						| tee  -a ~/tmp/$CASE_NUM/iscsi_reset.txt
echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/iscsi_reset.txt
sleep 2
rg -z "Removing initiator iqn" -g "stargate*"							  						| tee  -a ~/tmp/$CASE_NUM/iscsi_reset.txt								

echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/HBA_reset.txt			
echo "19. HBA reset reset " 											  						| tee  -a ~/tmp/$CASE_NUM/HBA_reset.txt
echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/HBA_reset.txt
sleep 2
rg -z "sending diag reset"											      						| tee  -a ~/tmp/$CASE_NUM/HBA_reset.txt

echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/Cerebro_bug-ENG24713.txt
echo "20. Cerebro bug ENG-247313 " 										  						| tee  -a ~/tmp/$CASE_NUM/Cerebro_bug-ENG24713.txt
echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/Cerebro_bug-ENG24713.txt
sleep 2
rg -z "Cannot reincarnate a previously detached entity without an incarnation_id" 				| tee  -a ~/tmp/$CASE_NUM/Cerebro_bug-ENG24713.txt

echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/Ergon_task_issue.txt	
echo "21. ergon task issue ENG-247313 " 								  						| tee  -a ~/tmp/$CASE_NUM/Ergon_task_issue.txt		
echo "#############################################" 					  						| tee  -a ~/tmp/$CASE_NUM/Ergon_task_issue.txt
sleep 2
rg -z "Cache sync with DB failed" -g "ergon.*"							  						| tee  -a ~/tmp/$CASE_NUM/Ergon_task_issue.txt
rg -z "Cache sync with DB failed" -g "minerva_ha_dispatcher.*"		      						| tee  -a ~/tmp/$CASE_NUM/Ergon_task_issue.txt

#echo "#############################################" 					
#echo "21. FATAL log check $filter ." 											
#echo "#############################################" 					
#sleep 2
#filter=F`(date '+%m%d')`
#rg -z $filter .	

echo "#############################################" 					
echo "sharepath info for engineering" 											
echo "#############################################"
chmod 777 -R ~/shared/$CASE_NUM
cd ~/shared/$CASE_NUM/*PE
sharepath
sleep 2