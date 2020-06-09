#!/usr/bin/env python3

#Script Name : nutanix_api_cli.py
#Script Purpose or Overview
# - this script can show cluster detail as json format in clustet menu
# - this script can show all disks in the cluster - mount point
# - this script will show cluster detail info if cluster is selected
# This file is developed by Taeho Choi(taeho.choi@nutanix.com) by referring below resources
# For reference look at:
# https://www.digitalformula.net/2018/api/vm-performance-stats-with-nutanix-rest-api/
# https://github.com/nelsonad77/acropolis-api-examples
# https://github.com/sandeep-car/perfmon/

#   disclaimer
#	This code is intended as a standalone example.  Subject to licensing restrictions defined on nutanix.dev, this can be downloaded, copied and/or modified in any way you see fit.
#	Please be aware that all public code samples provided by Nutanix are unofficial in nature, are provided as examples only, are unsupported and will need to be heavily scrutinized and potentially modified before they can be used in a production environment.
#   All such code samples are provided on an as-is basis, and Nutanix expressly disclaims all warranties, express or implied.
#	All code samples are © Nutanix, Inc., and are provided as-is under the MIT license. (https://opensource.org/licenses/MIT)

import sys
import requests
import urllib.request
import pandas as pd
import ipaddress
import urllib3
import getpass
from requests.auth import HTTPBasicAuth
import json
import pprint
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def GetCluster():
    print("What's Prism VIP address? ")
    VIP = input()
    if ipaddress.ip_address(VIP):
           print ("You typed right ip format")
    else:
      print ("You typed wrong ip format")
      print ("Existing")
    print("What is the Prism UI User which has admin role? ")
    username = input()
    password = getpass.getpass(prompt="What is the password for the Prism UI User?\n" , stream=None)
    return(VIP,username,password)

def PrismMenu(VIP):
    #baseUrl=str()
    baseUrl = "https://"+VIP+":9440/PrismGateway/services/rest/v2.0/"
    print("###############################################")
    print("What kind of information do you want to collect?")
    print("#################### MENU #################### ")
    print("Type 1: cluster info")
    print("Type 2: disk info")
    print("Type 3: hosts info")
    seLection = input()
    return seLection

def PrismDiskInfo(VIP,username,password):
    baseUrl = "https://"+VIP+":9440/PrismGateway/services/rest/v2.0/"
    print("#### Listing Disks.... #### in %s" %VIP)
    subpath = '/disks'
    ResPonse = requests.get(baseUrl+subpath, headers={'Accept': 'application/json'}, verify=False, auth=HTTPBasicAuth(username, password))
    ResPonse_json = json.loads(ResPonse.text)
    disk_count=len(ResPonse_json['entities'])

    #Create temp list to count SSD disk/HDD disk no.
    sto_tier=[]
    for n in ResPonse_json["entities"]:
        sto_tier.append(n["storage_tier_name"])

    #Printing total no of disks and SSD / HDD
    print("## Total no of disk is: {} SSD: {} HDD: {} ".format(disk_count,sto_tier.count("SSD"),sto_tier.count("HDD")))
    print("############################### \n")

    for n in ResPonse_json["entities"]:
                print("Disk id: " + n["disk_hardware_config"]["disk_id"].split(':')[-1])
                print("Disk SN: " + n["disk_hardware_config"]["serial_number"])
                print("Model Number: "+n["disk_hardware_config"]["model"])
                print("FW ver: " + n["disk_hardware_config"]["target_firmware_version"])
                print("CVM_IP: " + n["cvm_ip_address"])
                print("Slot location: "+ str(n["location"]))
                print("Is bad?: "+ str(n["disk_hardware_config"]["bad"]))
                print("Is mounted?: "+str(n["disk_hardware_config"]["mounted"]))
                print("Is online?: "+str(n["online"]))
                print("Storage Tier: "+ n["storage_tier_name"])
                print("Disk Size: %5.2f GB " % (float(n["disk_size"])/1024/1024/1024))
                print("###############################")

def PrismHosts(VIP,username,password):
    baseUrl = "https://"+VIP+":9440/PrismGateway/services/rest/v2.0/"
    print("########## Listing hosts from %s " %baseUrl)
    subpath = '/hosts'
    ResPonse = requests.get(baseUrl+subpath, headers={'Accept': 'application/json'}, verify=False, auth=HTTPBasicAuth(username, password))
    ResPonse_json = json.loads(ResPonse.text)
    hosts_count=len(ResPonse_json['entities'])
    print("########## There is(are) %s host(s), below is the detail ##########" %hosts_count)
    hostinfo={}
    #hostStatsDict = []
    for i in range(hosts_count):
        host_uuid = ResPonse_json['entities'][i]['uuid']
        host_name = ResPonse_json['entities'][i]['name']
        hostinfo.update({host_name:host_uuid})
        print ('{0}. host name {1} and uuid {2}'.format(i+1,host_name,host_uuid))

        #get each host detail
        uuidpath = host_uuid
        host_Detail = requests.get(baseUrl+subpath+'/'+uuidpath, headers={'Accept': 'application/json'}, verify=False, auth=HTTPBasicAuth(username, password))
        hostJson = json.loads(host_Detail.text)
        hostStatsDict = (hostJson["serial"],hostJson["num_cpu_threads"],
        hostJson["num_vms"],hostJson["bios_version"],
        hostJson["bmc_version"], hostJson["memory_capacity_in_bytes"],
        hostJson["hypervisor_full_name"],hostJson["metadata_store_status"])

        print("SN: %s" %hostJson["serial"])
        print("Block Model: %s" %hostJson["block_model_name"])
        print("CPU core: %s" %hostJson["num_cpu_threads"])
        print("Mem size(byte): %s"  %hostJson["memory_capacity_in_bytes"])
        print("No of VMs running: %s" %hostJson["num_vms"])
        print("BIOS version: %s" %hostJson["bios_version"])
        print("BMC version: %s" %hostJson["bmc_version"])
        print("Hypervisor Info: %s" %hostJson["hypervisor_full_name"])
        print("Metadata status %s" %hostJson["metadata_store_status"])
        #print(hostJson["hba_firmwares_list"])
        #print("HBA model %s" %(hostJson["hba_firmwares_list"]["hba_model"])
        #print("HBA FW version %s" %(hostJson["hba_firmwares_list"]["hba_version"])
        print("########################")


def PrismClusterInfo(VIP,username,password):
    baseUrl = "https://"+VIP+":9440/PrismGateway/services/rest/v2.0/"
    print("########## Show Cluster config detail.... in %s" %baseUrl)
    subpath = '/cluster'
    Cluster_detail = requests.get(baseUrl+subpath, headers={'Accept': 'application/json'}, verify=False, auth=HTTPBasicAuth(username, password))
    Cluster_detail_dict = json.loads(Cluster_detail.text)
    print(json.dumps(Cluster_detail_dict, indent=4))

if __name__ == '__main__':

    print("###############################################")
    print("You can also use $python3 %s Prism_VIP username password without interaction" %sys.argv[0])

    if len(sys.argv) == 4:
        # Get VIP username password from command line
        VIP = sys.argv[1]
        username = sys.argv[2]
        password = sys.argv[3]
    else:
        cluster = GetCluster()
        VIP = cluster[0]
        username = cluster[1]
        password = cluster[2]

    select = PrismMenu(VIP)
    if select == str(1):
        PrismClusterInfo(VIP,username,password)
    elif select == str(2):
        PrismDiskInfo(VIP,username,password)
    elif select == str(3):
        PrismHosts(VIP,username,password)
    else :
        print("Selected wrong option...")
        exit()
