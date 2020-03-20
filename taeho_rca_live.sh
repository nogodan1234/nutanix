#!/usr/bin/bash
# Disclaimer: Usage of this tool must be under guidance of Nutanix Administrator
# Summary: This is initial diagnostic script to detect known issues
# Version of the script: Version 1
# Compatible software version(s): AOS 5.10 above
# Brief syntax usage: nutanix$sh nutanix_diag.sh
# - output will be shown in std output also will be saved in ~/tmp dir 

echo "###########################" | tee ~/tmp/acro.txt
echo "Acropolis service check" | tee -a ~/tmp/acro.txt
echo "###########################" | tee -a ~/tmp/acro.txt

echo "###########################" | tee -a ~/tmp/acro.txt
echo "Displays AHV master changes" | tee -a ~/tmp/acro.txt
echo "###########################" | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Acquired master leadership"  ~/data/logs/acropolis.out*' ; done | tee -a ~/tmp/acro.txt

echo "###########################"     | tee -a ~/tmp/acro.txt
echo "Displays Acropolis crash events." | tee -a ~/tmp/acro.txt
echo "###########################"     | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Could not find parcels for VM"  ~/data/logs/acropolis.out*' ; done | tee -a ~/tmp/acro.txt

echo "###########################"     | tee -a ~/tmp/acro.txt
echo "Displays Acropolis crash events." | tee -a ~/tmp/acro.txt
echo "###########################"     | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "ValueError: bytes is not a 16-char string" ~/data/logs/acropolis.out*' ; done | tee -a ~/tmp/acro.txt

echo "###########################"     | tee -a ~/tmp/acro.txt
echo "Detecting multiple VM creation with same NIC UUID." | tee -a ~/tmp/acro.txt
echo "###########################"     | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "failed with error: virtual_nic with uuid" ~/data/logs/acropolis.out*' ;done | tee -a ~/tmp/acro.txt

echo "###########################"     | tee -a ~/tmp/acro.txt
echo "Acropolis crashes when there are VMs in the cluster with affinity and anti-affinity configured and enabling HA, to HA-RS(ENG-109729)" | tee -a ~/tmp/acro.txt
echo "###########################"     | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i  'zgrep "AcropolisNotFoundError: Unknown VmGroup:" ~/data/logs/acropolis.out*';done | tee -a ~/tmp/acro.txt

echo "###########################"     | tee -a ~/tmp/acro.txt
echo "Displays Acropolis crash due to abort migration events - ENG-232484, KB 7925, MTU check" | tee -a ~/tmp/acro.txt
echo "###########################"     | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i  'zgrep "Unable to find matching parcel for VM" ~/data/logs/acropolis.out*';done | tee -a ~/tmp/acro.txt

echo "###########################"     | tee -a ~/tmp/acro.txt
echo "Displays Acropolis crash due to master initialization taking too long - ENG-269432, KB 8630" | tee -a ~/tmp/acro.txt
echo "###########################"     | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i  'zgrep "Master initialization took longer than" ~/data/logs/acropolis.out*';done | tee -a ~/tmp/acro.txt

echo "###########################"     | tee -a ~/tmp/acro.txt
echo "Detecting if an image file is not present which is leading to image list failing in UI" | tee -a ~/tmp/acro.txt
echo "###########################"     | tee -a ~/tmp/acro.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i  'zgrep "failed with NFS3ERR_NOENT" ~/data/logs/catalog.out*';done | tee -a ~/tmp/acro.txt

echo "###########################" | tee ~/tmp/cass.txt
echo "Cassandra service check" | tee -a ~/tmp/cass.txt
echo "###########################" | tee -a ~/tmp/cass.txt

echo "###########################" | tee -a ~/tmp/cass.txt
echo "CASSANDRA_MON_HEALTH_WARNINING" | tee -a ~/tmp/cass.txt
echo "###########################" | tee -a ~/tmp/cass.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Attempting repair of local node due to health warnings received from cassandra"  ~/data/logs/cassandra_monitor.*' ; done | tee -a ~/tmp/cass.txt

echo "###########################" | tee -a ~/tmp/cass.txt
echo "Detecting if cassandra skipped scans" | tee -a ~/tmp/cass.txt
echo "###########################" | tee -a ~/tmp/cass.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Skipping scans for cf: "  ~/data/logs/dynamic_ring_changer.*' ; done | tee -a ~/tmp/cass.txt

echo "###########################" | tee -a ~/tmp/cass.txt
echo "Displays critical events" | tee -a ~/tmp/cass.txt
echo "###########################" | tee -a ~/tmp/cass.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Skipping row DecoratedKey"  ~/data/logs/cassandra/system.log*' ; done | tee -a ~/tmp/cass.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Fatal exception in thread"  ~/data/logs/cassandra/system.log*' ; done | tee -a ~/tmp/cass.txt


echo "###########################" | tee -a ~/tmp/aplos.txt
echo "Aplos LDAP login failure  "  | tee -a ~/tmp/aplos.txt
echo "###########################" | tee -a ~/tmp/aplos.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "This search operation has checked the maximum of 10000 entries for matches"  ~/data/logs/aplos.out*' ; done | tee -a ~/tmp/aplos.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "'desc': 'Bad search filter'"  ~/data/logs/aplos.out*' ; done | tee -a ~/tmp/aplos.txt

echo "###########################" | tee -a ~/tmp/aplos.txt
echo "SSP_MIGRATION_FAILS - KB 5919 "  | tee -a ~/tmp/aplos.txt
echo "###########################" | tee -a ~/tmp/aplos.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Directory service update failed kunden"  ~/data/logs/aplos.out*' ; done | tee -a ~/tmp/aplos.txt

echo "###########################" | tee -a ~/tmp/aplos.txt
echo "remote_cluster_uuid is not known or may be unregistered "  | tee -a ~/tmp/aplos.txt
echo "###########################" | tee -a ~/tmp/aplos.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "msecs, response status: 404"  ~/data/logs/aplos.out* | grep "remote_cluster_uuid="' ; done | tee -a ~/tmp/aplos.txt


echo "###########################" | tee -a ~/tmp/aplos_engine.txt
echo "Aplos engine VM snapshot failure "  | tee -a ~/tmp/aplos_engine.txt
echo "###########################" | tee -a ~/tmp/aplos_engine.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Timed out waiting for the completion of task"  ~/data/logs/aplos_engine.out*' ; done | tee -a ~/tmp/aplos_engine.txt

echo "###########################" | tee -a ~/tmp/kernel.txt
echo "Kernel child process hung "  | tee -a ~/tmp/kernel.txt
echo "CPU Unblock is hung.  See ENG-72597, ENG-258725 "  | tee -a ~/tmp/kernel.txt
echo "###########################" | tee -a ~/tmp/kernel.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'sudo zgrep "child is hung"  /home/log/messages*' ; done | tee -a ~/tmp/kernel.txt

echo "###########################" | tee -a ~/tmp/kernel.txt
echo "Firmware PH16 Detect - KB-6937"       | tee -a ~/tmp/kernel.txt
echo "###########################" | tee -a ~/tmp/kernel.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'sudo zgrep "LSISAS3008: FWVersion(16.00.01.00)"  /home/log/messages*' ; done | tee -a ~/tmp/kernel.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'sudo zgrep "mpt3sas_cm0: Command Timeout"  /home/log/messages*' ; done | tee -a ~/tmp/kernel.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'sudo zgrep "mpt3sas_cm0: sending diag reset"  /home/log/messages*' ; done | tee -a ~/tmp/kernel.txt

echo "###########################" | tee -a ~/tmp/prism_gateway.txt
echo "Tracking Prism Gateway OutOfMemory Errors"       | tee -a ~/tmp/prism_gateway.txt
echo "###########################" | tee -a ~/tmp/prism_gateway.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Throwing exception from VMAdministration.getVMs"  ~/data/logs/prism_gateway*' ; done | tee -a ~/tmp/prism_gateway.txt

echo "###########################" | tee -a ~/tmp/prism_gateway.txt
echo "RPC_PROTOBUF_ERROR"       | tee -a ~/tmp/prism_gateway.txt
echo "###########################" | tee -a ~/tmp/prism_gateway.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "InvalidProtocolBufferException: Protocol message was too large"  ~/data/logs/prism_gateway*' ; done | tee -a ~/tmp/prism_gateway.txt

echo "###########################" | tee -a ~/tmp/prism_gateway.txt
echo "APLOS_KEY_GENERATION_FAILED"       | tee -a ~/tmp/prism_gateway.txt
echo "###########################" | tee -a ~/tmp/prism_gateway.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Generate SSL Certificate failed. Error occurred while writing the private Key"  ~/data/logs/prism_gateway*' ; done | tee -a ~/tmp/prism_gateway.txt

echo "###########################" | tee -a ~/tmp/prism_gateway.txt
echo "CLUSTER_NOT_REACHABLE"       | tee -a ~/tmp/prism_gateway.txt
echo "###########################" | tee -a ~/tmp/prism_gateway.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Failed to write Zeus data java.lang.IllegalStateException: cluster not reachable"  ~/data/logs/prism_gateway*' ; done | tee -a ~/tmp/prism_gateway.txt

echo "###########################" | tee -a ~/tmp/prism_gateway.txt
echo "Backups failing due to conflicting files"       | tee -a ~/tmp/prism_gateway.txt
echo "###########################" | tee -a ~/tmp/prism_gateway.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Aborting the operation due to conflicting files"  ~/data/logs/prism_gateway*' ; done | tee -a ~/tmp/prism_gateway.txt

echo "###########################" | tee -a ~/tmp/prism_gateway.txt
echo "Backups failing due to conflicting files"       | tee -a ~/tmp/prism_gateway.txt
echo "###########################" | tee -a ~/tmp/prism_gateway.txt
for i in `svmips` ; do echo "==== $i ====" ; ssh -q $i 'zgrep "Aborting the operation due to conflicting files"  ~/data/logs/prism_gateway*' ; done | tee -a ~/tmp/prism_gateway.txt









