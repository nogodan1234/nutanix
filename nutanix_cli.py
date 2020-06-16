#!/usr/bin/env python3

#Script Name : nutanix_cli.py
#Script Purpose or Overview 
# - this script will show last 1 hr entity(cpu/mem) performance data - host, vm with interactive option as well as argv option.
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
import clusterconfig as C
import urllib3
import pprint
from itertools import chain, repeat
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import json
import pyperclip as pc

if __name__ == "__main__":
    cluster = C.GetClusterDetail()
    while True:    
        ip = cluster[0]
        username = cluster[1]
        password = cluster[2]  

        mycluster = C.my_api(ip,username,password)
        seLection = mycluster.EntityMenu()

        if seLection == str(1):
            print("You've selected cluster detail....\n")
            # 1. Call cluster detail from get_cluster_information() method with api v1
            status, all_cluster = mycluster.get_all_entity_info("cluster")
            print("Here is the cluster detail... \n")
            # 2. pprint cluter detail json format
            pprint.pprint(all_cluster)

        elif seLection == str(2):
            # 1. Get the UUID of all hosts.
            print("You've selected host detail....\n")
            status, all_hosts = mycluster.get_all_entity_info("hosts")

            # 2. Check the longest host name size to align print format
            hostName=[]
            for i in all_hosts["entities"]:
                hostName.append(i["name"])
            maxfield = len(max(hostName,key=len))

            # 3. Display all host name and uuid for user to select host by uuid
            for n in all_hosts["entities"]:
        	    print("Host name: " + n["name"].ljust(maxfield)+" uuid: " + n["uuid"].rjust(30))
            print("\n")
            # 4. Get VM UUID for specific host from standard input
            host_uuid=C.GetUUid()
            
            # 5. Display host detail for the uuid
            status, host_info = mycluster.get_single_ent_info("hosts",host_uuid)
            pprint.pprint(host_info)

            # 5. Get CPU stats from arithmos base interval 30 secs
            #status, resp = mycluster.get_resource_stats("host",host_uuid,"cpu")
            #stats = resp['statsSpecificResponses'][0]
            #if (stats['successful'] != True):
            #    print (">> CPU Stat call to", ip, "failed. Aborting... <<")
            #    sys.exit(1)
            #cpu_stats = stats['values']
            #i=0
            #cpu_min = sys.maxsize
            #cpu_max=0
            #running_total=0
            #for cpu in cpu_stats:
            #    if (cpu < cpu_min):
            #        cpu_min = int(cpu)
            #    if (cpu > cpu_max):
            #        cpu_max = int(cpu)
            #    running_total += int(cpu)
            #    i=i+1
            #print ("Percentage utilization last 1hr: CPU_MAX: %5.2f CPU_MIN: %5.2f CPU_AVG %5.2f" % (cpu_max/10000,cpu_min/10000,(running_total/10000)/i))

            # 6. Get MEM stats from arithmos base interval 30 secs
            #status, resp = mycluster.get_resource_stats("host",host_uuid,"memory")
            #stats = resp['statsSpecificResponses'][0]
            #if (stats['successful'] != True):
            #    print (">> Memory Stat call to",ip, "failed. Aborting... <<")
            #    sys.exit(1)
            #mem_stats = stats['values']
            #i=0
            #mem_min = sys.maxsize
            #mem_max=0
            #running_total=0
            #for mem in mem_stats:
            #    if (mem < mem_min):
            #        mem_min = int(mem)
            #    if (mem > mem_max):
            #        mem_max = int(mem)
            #    running_total += int(mem)
            #    i=i+1
            #print ("Percentage utilization last 1hr: MEM_MAX: %5.2f MEM_MIN: %5.2f MEM_AVG %5.2f" % (mem_max/10000,mem_min/10000,(running_total/10000)/i))

        elif seLection == str(3):
            print("You've selected VM detail....\n")
            # 1. Get the UUID of all VMs.
            status, all_vms = mycluster.get_all_entity_info("vms")

            # 2. Check the longest VM name size to align print format
            vmName=[]
            for i in all_vms["entities"]:
                vmName.append(i["vmName"])
            maxfield = len(max(vmName,key=len))

            # 3. Display all vm name and uuid for user to select VM by uuid
            for n in all_vms["entities"]:
                print("VM name: " + n["vmName"].ljust(maxfield)+" uuid: " + n["uuid"].ljust(40)+ "power:"+n["powerState"])
            print("\n")
            # 4. Get VM UUID for specific VM from standard input
            vm_uuid = C.GetUUid()

            # 5. Display host detail for the uuid
            status, vm_info = mycluster.get_single_ent_info("vms",vm_uuid)
            pprint.pprint(vm_info)

            # 5. Get CPU stats from arithmos base interval 30 secs
            #status, resp = mycluster.get_resource_stats("vm",vm_uuid,"cpu")
            #stats = resp['statsSpecificResponses'][0]
            #if (stats['successful'] != True):
            #    print (">> CPU Stat call to", ip, "failed. Aborting... <<")
            #    sys.exit(1)
            #cpu_stats = stats['values']
            #i=0
            #cpu_min = sys.maxsize
            #cpu_max=0
            #running_total=0
            #for cpu in cpu_stats:
            #    if (cpu < cpu_min):
            #        cpu_min = int(cpu)
            #    if (cpu > cpu_max):
            #        cpu_max = int(cpu)
            #    running_total += int(cpu)
            #    i=i+1
            #print ("Percentage utilization last 1hr: CPU_MAX: %5.2f CPU_MIN: %5.2f CPU_AVG %5.2f" % (cpu_max/10000,cpu_min/10000,(running_total/10000)/i))

            # 6. Get MEM stats from arithmos base interval 30 secs
            #status, resp = mycluster.get_resource_stats("vm",vm_uuid,"memory")
            #stats = resp['statsSpecificResponses'][0]
            #if (stats['successful'] != True):
            #    print (">> Memory Stat call to",ip, "failed. Aborting... <<")
            #    sys.exit(1)
            #mem_stats = stats['values']
            #i=0
            #mem_min = sys.maxsize
            #mem_max=0
            #running_total=0
            #for mem in mem_stats:
            #    if (mem < mem_min):
            #        mem_min = int(mem)
            #    if (mem > mem_max):
            #        mem_max = int(mem)
            #    running_total += int(mem)
            #    i=i+1
            #print ("Percentage utilization last 1hr: MEM_MAX: %5.2f MEM_MIN: %5.2f MEM_AVG %5.2f" % (mem_max/10000,mem_min/10000,(running_total/10000)/i))

        elif seLection == str(4):
            print("You've selected Image detail....\n")
            # 1. Get the UUID of all imgs.
            status, all_imgs = mycluster.get_all_entity_info("images")

            # 2. Check the longest img name size to align print format
            imgName=[]
            for i in all_imgs["entities"]:
                imgName.append(i["name"])
            maxfield = len(max(imgName,key=len))

            # 3. Display all img name, uuid, img_type: ISO or disk
            for n in all_imgs["entities"]:
                print("Image name: " + n["name"].ljust(maxfield)+" uuid: " + n["uuid"] +" vm_disk_id: " + str(n.get("vm_disk_id")) + "  image_type: "+ str(n.get("image_type")))
            print("\n")
            
            # 4. Get image uuid from the list
            img_uuid=C.GetUUid()
            
            # 5. Display host detail for the uuid
            status, ent_info = mycluster.get_single_ent_info("images",img_uuid)
            pprint.pprint(ent_info)

        elif seLection == str(5):
            print("You've selected container info detail....\n")
            # 1. Get the UUID of container 
            status, all_ctrs = mycluster.get_all_entity_info("ctr")

            # 2. Check the longest ctr name size to align print format
            ctrName=[]
            for i in all_ctrs["entities"]:
                ctrName.append(i["name"])
            maxfield = len(max(ctrName,key=len))

            # 3. Display all ctr name, uuid, img_type: ISO or disk
            for n in all_ctrs["entities"]:
                print("Container name: " + n["name"].ljust(maxfield)+" storage_container_uuid: " + n["storage_container_uuid"].ljust(40))
            print("\n")
            
            # 4. Get ctr UUID 
            ctr_uuid=C.GetUUid()
            
            # 5. Display host detail for the uuid
            status, ent_info = mycluster.get_single_ent_info("ctr",ctr_uuid)
            pprint.pprint(ent_info)

        elif seLection == str(6):
            print("You've selected network info detail....\n")
            # 1. Get the UUID of network 
            status, all_nets = mycluster.get_all_entity_info("net")

            # 2. Check the longest ctr name size to align print format
            netName=[]
            for i in all_nets["entities"]:
                netName.append(i["name"])
            maxfield = len(max(netName,key=len))

            # 3. Display all ctr name, uuid, img_type: ISO or disk
            for n in all_nets["entities"]:
                print("Network name: " + n["name"].ljust(maxfield)+" network uuid: " + n["uuid"] + "  vlan: "+ str(n["vlan_id"]).ljust(6)+"  dhcp option:" + str(n["ip_config"]["dhcp_options"]))
            print("\n")

            # 4. Get image uuid from the list
            net_uuid=C.GetUUid()
            
            # 5. Display host detail for the uuid
            status, ent_info = mycluster.get_single_ent_info("net",net_uuid)
            pprint.pprint(ent_info) 

            print("\nBelow is detail ip usage if it is managed network\n")
            #6. Display subnet usage detail for the uuid
            status, ent_info = mycluster.get_single_ent_info("net2",net_uuid)
            pprint.pprint(ent_info) 

        elif seLection == str(7):
            print("You've selected to publish new image from url..\n")
            name        = input("Enter the image_name: ")
            annotation  = input("Enther image annotation (optional): ")

            #Limiting input for image_type only 2 available options with itertool
            img_type    = {'DISK_IMAGE','ISO_IMAGE'}
            image_input = chain(["Enter image type - DISK_IMAGE or ISO_IMAGE: "], repeat("Please type correct image type again: "))
            replies     = map(input, image_input)
            valid_image = next(filter(img_type.__contains__, replies))
            
            ctrUuid     = input("Enter container uuid where you want to store this: ")
            url         = input("Enter URL where the image is located: ")
            body = {"name":name,"annotation":annotation,"imageType":valid_image,"imageImportSpec":{"containerUuid":ctrUuid,"url":url}}
            #body = {"name":"cirros_disk2","annotation":"cirros","imageType":"DISK_IMAGE","imageImportSpec":{"containerUuid":"f8943a0e-83de-41c7-9627-08d2b25c72fb","url":"https://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img"}}
            status,task_uuid = mycluster.post_new_img(body)
            print ("\n\nServer Response code is: {} and task uuid is {}".format(status,task_uuid["taskUuid"]))
            print("\n")
            status, ent_info = mycluster.get_single_ent_info("tasks",task_uuid["taskUuid"])
            pprint.pprint(ent_info)
            print("\n")

        elif seLection == str(8):
            print("You've selected to create new VM with cloud-init..\n")
            print("This task will create ONLY from disk image in image list\n")
            body={"name":str,"memory_mb":int,"num_vcpus":int,"description":str,"num_cores_per_vcpu":int,"timezone":str,"boot":{"uefi_boot":False,"boot_device_order":["CDROM","DISK","NIC"]},"vm_disks":[{"is_cdrom":False,"disk_address":{"device_bus":"scsi"},"vm_disk_clone":{"disk_address":{"vmdisk_uuid":str},"minimum_size":int}}],"vm_nics":[{"network_uuid":str,"is_connected":True}],"hypervisor_type":"ACROPOLIS","vm_customization_config":{"userdata":str,"files_to_inject_list":[]},"vm_features":{"AGENT_VM":False}}
            
            body["name"]                                                        = input("Enter VM name: ")
            body["num_vcpus"]                                                   = int(input("Enter num of vcpus: "))
            body["num_cores_per_vcpu"]                                          = int(input("Enter num of vcpu per sockets: "))
            body["memory_mb"]                                                   = 1024*int(input("Enter VM memory size(GB): "))
            body["description"]                                                 = input("Enter VM description: ")
            body["timezone"]                                                    = input("Enter timezone ex) UTC: ")
            body["vm_nics"][0]["network_uuid"]                                  = input("Enter network uuid: ")
            body["vm_disks"][0]["vm_disk_clone"]["disk_address"]["vmdisk_uuid"] = input("Enter vmdisk_id for disk image: ")
            body["vm_disks"][0]["vm_disk_clone"]["minimum_size"]                = 1024*1024*1024*int(input("Enter vmdisk size(GB) : "))

            print("Please place your cloud-init file in same dir with this script ... ")  

            cl_int_f                                                            = input("Enter cloud-init filename ")
            fd_cl_int_f = open(cl_int_f,"r")
            body["vm_customization_config"]["userdata"]                         = fd_cl_int_f.read()
            fd_cl_int_f.close()

            #if input("Type Y to copy clipboard content to cloud-init config, N to exit: ") == "Y":
            #    body["vm_customization_config"]["userdata"] = pc.paste()
            #    print("Your cloud-init config is %s" %body["vm_customization_config"]["userdata"])
            #else:
            #    print("exit")            
            status,task_uuid = mycluster.create_vm(body)
            print ("\n\nServer Response code is: {} and task uuid is {}".format(status,task_uuid["task_uuid"]))
            print("\n")
            status, ent_info = mycluster.get_single_ent_info("tasks",task_uuid["task_uuid"])
            pprint.pprint(ent_info)
            print("\n") 

        elif seLection == str(9):
            print("You've selected to VM power operation\n")
            body = {"transition": str,"uuid": str}
            body["uuid"] = input("Enter vm uuid for power operation: ")

            #Limiting input for power status only 2 available options with itertool
            pwr_stat    = {'ON','OFF'}
            stat_input  = chain(["Enter the new power status of the vm - ON or OFF: "], repeat("Please type correct power status again: "))
            replies     = map(input, stat_input)
            body["transition"] = next(filter(pwr_stat.__contains__, replies))
            status,task_uuid = mycluster.vm_powerop(body,body["uuid"])
            print ("\n\nServer Response code is: {} and task uuid is {}".format(status,task_uuid["task_uuid"]))
            print("\n")
            status, ent_info = mycluster.get_single_ent_info("tasks",task_uuid["task_uuid"])
            pprint.pprint(ent_info)
            print("\n")

        elif seLection == str(10):
            print("You've selected to VM delete operation\n")
            body = {"uuid": str}
            
            # 1. Collect all current vm uuids 
            status, all_vms = mycluster.get_all_entity_info("vms")

            # 2. Check the longest VM name size to align print format
            vmName=[]
            for i in all_vms["entities"]:
                vmName.append(i["vmName"])
            maxfield = len(max(vmName,key=len))
            
            # 3. Display all vm name and uuid for user to select VM by uuid
            for n in all_vms["entities"]:
                print("VM name: " + n["vmName"].ljust(maxfield)+" uuid: " + n["uuid"].ljust(40)+ "power:"+n["powerState"])
            print("\n")

            # 4. Creating valid UUid list and compare whether input is valid
            vmUUid=[]
            for i in all_vms["entities"]:
                vmUUid.append(i["uuid"])

            # 5. Get an uuid input as long as it is valid
            stat_input  = chain(["Enter vm uuid to DELETE operation: "], repeat("Please type correct VM Uuid: "))
            replies     = map(input, stat_input)
            body["uuid"] = next(filter(vmUUid.__contains__, replies))
            status,task_uuid = mycluster.delete_vm(body,body["uuid"])
            print ("\n\nServer Response code is: {} and task uuid is {}".format(status,task_uuid["task_uuid"]))
            print("\n")
            status, ent_info = mycluster.get_single_ent_info("tasks",task_uuid["task_uuid"])
            pprint.pprint(ent_info)
            print("\n") 
                   
        else :
            print("You've selected wrong option")
            print("Exiting...")
            