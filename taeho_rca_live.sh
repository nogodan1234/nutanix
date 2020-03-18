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




