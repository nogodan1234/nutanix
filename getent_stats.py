#!/usr/local/bin/python3.7

#Script Name : getent_stats.py
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
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

if __name__ == "__main__":
        
        cluster = C.GetClusterDetail()
        ip = cluster[0]
        username = cluster[1]
        password = cluster[2]  

        mycluster = C.my_api(ip,username,password)
        seLection = mycluster.EntityMenu()

        if seLection == str(1):
            print("You've selected cluster detail....\n")
            # 1. Call cluster detail from get_cluster_information() method with api v1
            status, all_cluster = mycluster.get_cluster_information()
            print("Here is the cluster detail... \n")
            # 2. pprint cluter detail json format
            pprint.pprint(all_cluster)

        elif seLection == str(2):
            # 1. Get the UUID of all hosts.
            print("You've selected host detail....\n")
            status, all_hosts = mycluster.get_all_host_info()

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

            # 5. Get CPU stats from arithmos base interval 30 secs
            status, resp = mycluster.get_resource_stats("host",host_uuid,"cpu")
            stats = resp['statsSpecificResponses'][0]
            if (stats['successful'] != True):
                print (">> CPU Stat call to", ip, "failed. Aborting... <<")
                sys.exit(1)
            cpu_stats = stats['values']
            i=0
            cpu_min = sys.maxsize
            cpu_max=0
            running_total=0
            for cpu in cpu_stats:
                if (cpu < cpu_min):
                    cpu_min = int(cpu)
                if (cpu > cpu_max):
                    cpu_max = int(cpu)
                running_total += int(cpu)
                i=i+1
            print ("Percentage utilization last 1hr: CPU_MAX: %5.2f CPU_MIN: %5.2f CPU_AVG %5.2f" % (cpu_max/10000,cpu_min/10000,(running_total/10000)/i))

            # 6. Get MEM stats from arithmos base interval 30 secs
            status, resp = mycluster.get_resource_stats("host",host_uuid,"memory")
            stats = resp['statsSpecificResponses'][0]
            if (stats['successful'] != True):
                print (">> Memory Stat call to",ip, "failed. Aborting... <<")
                sys.exit(1)
            mem_stats = stats['values']
            i=0
            mem_min = sys.maxsize
            mem_max=0
            running_total=0
            for mem in mem_stats:
                if (mem < mem_min):
                    mem_min = int(mem)
                if (mem > mem_max):
                    mem_max = int(mem)
                running_total += int(mem)
                i=i+1
            print ("Percentage utilization last 1hr: MEM_MAX: %5.2f MEM_MIN: %5.2f MEM_AVG %5.2f" % (mem_max/10000,mem_min/10000,(running_total/10000)/i))
            sys.exit(0)

        elif seLection == str(3):
            print("You've selected VM detail....\n")
            # 1. Get the UUID of all VMs.
            status, all_vms = mycluster.get_all_vm_info()

            # 2. Check the longest VM name size to align print format
            vmName=[]
            for i in all_vms["entities"]:
                vmName.append(i["vmName"])
            maxfield = len(max(vmName,key=len))

            # 3. Display all vm name and uuid for user to select VM by uuid
            for n in all_vms["entities"]:
                print("VM name: " + n["vmName"].ljust(maxfield)+'\t'+" uuid: " + n["uuid"].ljust(40))
            print("\n")
            # 4. Get VM UUID for specific VM from standard input
            vm_uuid = C.GetUUid()
            
            # 5. Get CPU stats from arithmos base interval 30 secs
            status, resp = mycluster.get_resource_stats("vm",vm_uuid,"cpu")
            stats = resp['statsSpecificResponses'][0]
            if (stats['successful'] != True):
                print (">> CPU Stat call to", ip, "failed. Aborting... <<")
                sys.exit(1)
            cpu_stats = stats['values']
            i=0
            cpu_min = sys.maxsize
            cpu_max=0
            running_total=0
            for cpu in cpu_stats:
                if (cpu < cpu_min):
                    cpu_min = int(cpu)
                if (cpu > cpu_max):
                    cpu_max = int(cpu)
                running_total += int(cpu)
                i=i+1
            print ("Percentage utilization last 1hr: CPU_MAX: %5.2f CPU_MIN: %5.2f CPU_AVG %5.2f" % (cpu_max/10000,cpu_min/10000,(running_total/10000)/i))

            # 6. Get MEM stats from arithmos base interval 30 secs
            status, resp = mycluster.get_resource_stats("vm",vm_uuid,"memory")
            stats = resp['statsSpecificResponses'][0]
            if (stats['successful'] != True):
                print (">> Memory Stat call to",ip, "failed. Aborting... <<")
                sys.exit(1)
            mem_stats = stats['values']
            i=0
            mem_min = sys.maxsize
            mem_max=0
            running_total=0
            for mem in mem_stats:
                if (mem < mem_min):
                    mem_min = int(mem)
                if (mem > mem_max):
                    mem_max = int(mem)
                running_total += int(mem)
                i=i+1
            print ("Percentage utilization last 1hr: MEM_MAX: %5.2f MEM_MIN: %5.2f MEM_AVG %5.2f" % (mem_max/10000,mem_min/10000,(running_total/10000)/i))
            sys.exit(0)

        else :
            print("You've selected wrong option")
            print("Exiting...")
            sys.exit()