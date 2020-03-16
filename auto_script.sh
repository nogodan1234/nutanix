#!/bin/bash

# Basic shell script to take an existing Nutanix cluster running the Acropolis Hypervisor (AHV) and configure the Image Service, untagged VLAN and 3x virtual machines.
# All done using the Acropolis CLI (/usr/local/nutanix/bin/acli)

export TERM=linux

# set some variables
# change these to match your environment
# note that not all options are set here - just the settings most likely to change in a demo environment (in my opinion)

#NFS_SERVER=10.10.10.243
#NFS_EXPORT=Shared/Software

export CENTOS_IMAGE=https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1907.qcow2
export UBUNTU_IMAGE=https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img
#WINDOWS_ISO=$NFS_EXPORT/Microsoft/Windows_Server_2012_R2_Datacenter_Customer_VLK_2015.05.18/SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-4_MLF_X19-82891.ISO
#export PRISM_CENTRAL_BOOT_ISO=http://download.nutanix.com/downloads/kvm/5.10.0.1/5.10.0.1-prism_central-boot.qcow2?Expires=1544690536&Signature=MvXAoEYcu~fnSycK39k5xTMQaO0gcU7qIgHLpl4o6p0TYVPrpZtF2xp0GIvl4tUB0msR0ENcAXw9-cKwmydIhCb4kUcNPAldOZhL76~6~gZecUAINu3l6QmZfdACKECOaRYc7ITVsvEW1rdPWKphS1XP0WBvAR~X0EA9QCKG~swjnQdiAzQNu~HO2hTJ-kslCo6-UvAff4yGjzl615NSDYsft430HbG3I6UOz7oue9KQZFnjeJtI5zNNV7V6GQf7ioBwCSZ3tC113dfuBIYF8SZ66SncoEg0W3TriyJMpkEelCUvr7Z6CPiHICb0f6rcoB2p5-Y2~jPkJ775C9TZOw__&Key-Pair-Id=APKAJTTNCWPEI42QKMSA;

export DHCP_NET=dhcp
export DHCP_VLAN=102
export STATIC_NET=matrix
export STATIC_VLAN=0
export IP_CONFIG=10.2.124.1/22
export IP_POOL_START=10.2.127.11
export IP_POOL_END=10.2.127.14
#VLAN_IP_CONFIG=10.10.10.253/24
#DHCP_START=10.10.10.100
#DHCP_END=10.10.10.200
export DOMAIN_NAME=taeho.local
export DNS_SERVER=10.2.120.10
export WINDOWS_DISK_SIZE=40G
export CENTOS_DISK_SIZE=10G
#export PRISM_CENTRAL_CPUS=8
#export PRISM_CENTRAL_RAM=24G
#export PRISM_CENTRAL_IP=10.134.87.26
export PE_DATA_SVC_IP=10.2.127.99
#export ACS_CENTOS=http://download.nutanix.com/karbon/0.8/acs-centos7.qcow2
#export ACS_CENTOS=http://filer.dev.eng.nutanix.com:8080/Users/basu/ACS2.0/acs-centos7.qcow2
#export ACS_UBUNTU=http://download.nutanix.com/karbon/0.8/acs-ubuntu1604.qcow2
#export ACS_UBUNTU=http://filer.dev.eng.nutanix.com:8080/Users/basu/ACS2.0/acs-ubuntu1804.qcow2
#Object network
export OBJECT_DOMAIN_NAME=object.local
export OBJECT_NET=object_net
export OBJECT_VLAN=103
export OBJECT_IP_CONFIG=10.2.123.1/22
export OBJECT_IP_POOL_START=10.2.123.21
export OBJECT_IP_POOL_END=10.2.123.32

echo

# create images
# sleep for 3 seconds between each image creation process
# this is because the dev platform is based on OS X - NFS seems to disconnect clients if one session finishes then another immediately starts

#echo "Creating ACS images ..."
#/usr/local/nutanix/bin/acli image.create "acs-centos" image_type=kDiskImage source_url=$ACS_CENTOS container=NutanixManagementShare;
#sleep 3
#/usr/local/nutanix/bin/acli image.create "acs-ubuntu" image_type=kDiskImage source_url=$ACS_UBUNTU container=NutanixManagementShare;
#sleep 3
#echo "Creating Centos/Ubuntu images ..."
#/usr/local/nutanix/bin/acli image.create "centos-img" image_type=kDiskImage source_url=$CENTOS_IMAGE container=NutanixManagementShare;
#sleep 3
#/usr/local/nutanix/bin/acli image.create "ubuntu-img" image_type=kDiskImage source_url=$UBUNTU_IMAGE container=NutanixManagementShare;
#sleep 3
#echo "Creating Windows 2012 R2 ISO_image "
#/usr/local/nutanix/bin/acli image.create "Windows 2012 R2" image_type=kIsoImage source_url="http://apac-file.sre-labs.nutanix.com/Repo/Mounts/NSS/Win2012_R2-3319595.iso" container=NutanixManagementShare;
#sleep 3
#echo "Creating Centos7 Disk iamge "
#/usr/local/nutanix/bin/acli image.create "Centos7" image_type=kDiskImage source_url=$CENTOS_IMAGE container=Images;
#sleep 3
#echo "Creating VirtIO Driver image ..."
#/usr/local/nutanix/bin/acli image.create "VirtIO" image_type=kIsoImage source_url="http://apac-file.sre-labs.nutanix.com/Repo/Mounts/NSS/virtio-win-0.1.126.iso" container=NutanixManagementShare;

echo

# create network
echo "Creating dhcp network ..."
/usr/local/nutanix/bin/acli net.create dhcp vlan=$DHCP_VLAN 
sleep 3
echo "Creating Static network"
/usr/local/nutanix/bin/acli net.create $STATIC_NET vlan=$STATIC_VLAN ip_config=$IP_CONFIG 
echo "Adding DHCP pool ..."
/usr/local/nutanix/bin/acli net.add_dhcp_pool $STATIC_NET start=$IP_POOL_START end=$IP_POOL_END;
echo "Configuring $VLAN_NAME DNS settings ..."
/usr/local/nutanix/bin/acli net.update_dhcp_dns $STATIC_NET domains=$DOMAIN_NAME servers=$DNS_SERVER;

# create Object network
echo "Creating Object Static network"
/usr/local/nutanix/bin/acli net.create $OBJECT_NET vlan=$OBJECT_VLAN ip_config=$OBJECT_IP_CONFIG 
echo "Adding DHCP pool ..."
/usr/local/nutanix/bin/acli net.add_dhcp_pool $OBJECT_NET start=$OBJECT_IP_POOL_START end=$OBJECT_IP_POOL_END;
echo "Configuring $VLAN_NAME DNS settings ..."
/usr/local/nutanix/bin/acli net.update_dhcp_dns $OBJECT_NET domains=$OBJECT_DOMAIN_NAME servers=$DNS_SERVER;

echo

# create VMs - Windows 2012
#echo "Creating Windows 2012 R2 VM ..."
#/usr/local/nutanix/bin/acli vm.create "Windows2012R2" num_vcpus=1 num_cores_per_vcpu=1 memory=8G;
#echo "Attaching CDROM devices ..."
#/usr/local/nutanix/bin/acli vm.disk_create "Windows2012R2" cdrom=true clone_from_image="Windows 2012 R2";
#/usr/local/nutanix/bin/acli vm.disk_create "Windows2012R2" cdrom=true clone_from_image="VirtIO";
#echo "Creating system disk ..."
#/usr/local/nutanix/bin/acli vm.disk_create "Windows2012R2" create_size=$WINDOWS_DISK_SIZE;
#echo "Creating network adapter ..."
#/usr/local/nutanix/bin/acli vm.nic_create "Windows2012R2" network=$VLAN_NAME;
#echo "Powering on Windows 2012 R2 VM ..."
#/usr/local/nutanix/bin/acli vm.on "Windows2012R2";

echo

# create VMs - CentOS 7
#echo "Creating CentOS 7 VM ..."
#/usr/local/nutanix/bin/acli vm.create "CentOS7" num_vcpus=4 num_cores_per_vcpu=1 memory=2G;
#echo "Attaching boot disk device ..."
#/usr/local/nutanix/bin/acli vm.disk_create "CentOS7" clone_from_image=$CENTOS_IMAGE;
#echo "Creating network adapter ..."
#/usr/local/nutanix/bin/acli vm.nic_create "CentOS7" network=$DHCP_NET;
#echo "Powering on CentOS 7 VM ..."
#/usr/local/nutanix/bin/acli vm.on "CentOS7";

echo

# create VMs - Prism Central
matrix_net_id=`/usr/local/nutanix/bin/acli net.list | grep -i matrix | awk -F" " '{print $2}'`
default_storage_uuid=`/home/nutanix/prism/cli/ncli ctr ls | grep NutanixManagement -b2 | grep -i Uuid | grep -v Storage |  awk -F" " '{print $4}'`
#curl 'https://10.19.134.60:9440/api/nutanix/v3/prism_central' -H 'Origin: https://10.19.134.60:9440' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,ko;q=0.8'  -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: https://10.19.134.60:9440/console/'  -H 'Connection: keep-alive' -H 'X-Nutanix-Client-Type: ui' --data-binary '{"resources":{"version":"5.9.2","should_auto_register":true,"pc_vm_list":[{"vm_name":"PC5.9.2","container_uuid":$default_storage_uuid,"num_sockets":8,"data_disk_size_bytes":2684354560000,"memory_size_bytes":34359738368,"dns_server_ip_list":["10.19.128.10"],"nic_list":[{"ip_list":[$PRISM_CENTRAL_IP],"network_configuration":{"network_uuid":$matrix_net_id,"subnet_mask":"255.255.252.0","default_gateway":"10.19.132.1"}}]}]}}' --compressed --insecure -u admin:Nutanix/4u!
#rsh $PRISM_CENTRAL_IP -l nutanix cluster --cluster_function_list="multicluster" -s static_ip_address create

echo
echo "Finished!"
echo

#Prism UI passwd reset
#/home/nutanix/prism/cli/ncli user reset-password user-name=admin password=Nutanix/4u!
/home/nutanix/prism/cli/ncli cluster edit-params external-data-services-ip-address=$PE_DATA_SVC_IP
#/home/nutanix/prism/cli/ncli cluster add-public-key name="pub-key"


#API
#curl --request POST \
#  --url https://10.19.134.60:9440/PrismGateway/services/rest/v2.0/cluster/public_keys/ \
#  --header 'accept: application/json' \
# --header 'authorization: Basic YWRtaW46SGFycmlzQGRtMW4wOQ==' \
# --header 'content-type: application/json' \
#  --cookie 'NTNX_SESSION_META=%7B%22uuid%22%3A%228cc0e966-ccc8-4578-aa77-dfcb809d3b92%22%7D; JSESSIONID=.eJxdj0tvwjAQhP-LzxjRB-RxQzQHpFCkhLSHqrIWeykrOY5lO60qxH-voYFDjjv7zczuiQmLrgWDJrA8uB4nrO9JsZylUs4wWyy4lDLlz_Mk5QBJwtVB7tNZpp722SOLtEcXfi1GR7ldLcsoQR-OMY8kBFS3VOi8-EbnqTMRxd4eXVx7Pp9m09n0gfsAe42Du3MUCD3LP1i1LQuxacrdelU29a6oxPJls36N4HXT1GPlhr2ti_eiYp8TZh0ZSRa0MNBeDgXVkhluF9Z1B4rN-ek6jxAL3v90Lr5heq0nTHcSLjBDw5s6Ag6_hpcG4UDOh6Hp39OSUhoFmfgU6HsSjDBsgbSgoep8_gMZGYfM.DvTInA.Au1wtPZ_PlXOH5eSZpjsvJnk9QMQInGo7tsjcWpDc6LJCXBiUHk0iP25lPnvQOIi7fqoETFOkyquzogtdbKxbw' \
#  --data '{ "key":
#"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnWNa4I9QT8PkiuYtPmNNdtGmR6pYnLQgZ6tEG9+FzPBrNmn59leATGaFwis1/Up8qyqClSdSxJY10bNiAx8fLdK5x5T42I7h3JEwHo72wQx4tazeNRfeU9zrAuokKNMVklC6H2RUDryJ6BLWG/MPiNvtiLhg8oPSYeJk4RPhZPQQWU2p0NysUJyu8fgsGms/vq6r2fLLQxgXMtYv+AvrKnXL2jYO2oqb/KJOfY8DZeqdJPU6ZZVQ7IURT/1J00GNUNkVwTmbgEw7MCebDrFdsO2z9VwMl/YXJHDXlkI2/e3zTBElJBrlrtwMRyy9CZMyN5LHommNPmEJ0ydj2R/uL taeho@Taehos-MacBook-Pro.local","name":"taeho"}
#'

echo "########## Matrix_net_id ##########"
echo $matrix_net_id
echo "########## default_storage_uuid ############"
echo $default_storage_uuid

# qemu-img resize bionic-server-cloudimg-amd64.img 10G
# qemu-img info CentOS-7-x86_64-GenericCloud-1809.qcow2
#Cloud Init Script


#Prism Central info
#Check network uuid
#nuclei subnet.list
#nuclei cluster.list
#nuclei volume_group.list