#Script Name : clusterconfig.py
#Script Purpose or Overview : This python file contains basic nutanix api method and class to connect Nutanix cluster via api
#This file is developed by Taeho Choi(taeho.choi@nutanix.com) by referring below resources
# For reference look at:
# https://www.digitalformula.net/2018/api/vm-performance-stats-with-nutanix-rest-api/
# https://github.com/nelsonad77/acropolis-api-examples
# https://github.com/sandeep-car/perfmon/

#   disclaimer
#	This code is intended as a standalone example.  Subject to licensing restrictions defined on nutanix.dev, this can be downloaded, copied and/or modified in any way you see fit.
#	Please be aware that all public code samples provided by Nutanix are unofficial in nature, are provided as examples only, are unsupported and will need to be heavily scrutinized and potentially modified before they can be used in a production environment.  
#   All such code samples are provided on an as-is basis, and Nutanix expressly disclaims all warranties, express or implied.
#	All code samples are © Nutanix, Inc., and are provided as-is under the MIT license. (https://opensource.org/licenses/MIT)

import json,sys
import time
import requests
from urllib.parse import quote
import urllib3
import ipaddress
import getpass
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


# Time period is one hour (3600 seconds).
period=3600

# ========== DO NOT CHANGE ANYTHING UNDER THIS LINE =====
class my_api():
    def __init__(self,ip,username,password):

        # Cluster IP, username, password.
        self.ip_addr = ip
        self.username = username
        self.password = password

        # Base URL at which v0.8 REST services are hosted in Prism Gateway.
        base_urlv08 = 'https://%s:9440/PrismGateway/services/rest/v0.8/'
        self.base_urlv08 = base_urlv08 % self.ip_addr
        self.sessionv08 = self.get_server_session(self.username, self.password) 

        # Base URL at which v1 REST services are hosted in Prism Gateway.
        base_urlv1 = 'https://%s:9440/PrismGateway/services/rest/v1/'
        self.base_urlv1 = base_urlv1 % self.ip_addr
        self.sessionv1 = self.get_server_session(self.username, self.password)
        # Base URL at which v2 REST services are hosted in Prism Gateway.
        base_urlv2 = 'https://%s:9440/PrismGateway/services/rest/v2.0/'
        self.base_urlv2 = base_urlv2 % self.ip_addr
        self.sessionv2 = self.get_server_session(self.username, self.password)       
        # Base URL at which v3 REST services are hosted in Prism Gateway.
        base_urlv3 = 'https://%s:9440/PrismGateway/services/rest/v3/'
        self.base_urlv3 = base_urlv3 % self.ip_addr
        self.sessionv3 = self.get_server_session(self.username, self.password)    

    def get_server_session(self, username, password):

        # Creating REST client session for server connection, after globally
        # setting authorization, content type, and character set.
        session = requests.Session()
        session.auth = (username, password)
        session.verify = False
        session.headers.update({'Content-Type': 'application/json; charset=utf-8'})
        return session

    # Get cluster information.
    def get_cluster_information(self):

        cluster_url = self.base_urlv1 + "cluster/"
        print("Getting cluster information for cluster %s." % self.ip_addr)
        server_response = self.sessionv1.get(cluster_url)
        return server_response.status_code ,json.loads(server_response.text)

        # Get host information.
    def get_all_host_info(self):

        cluster_url = self.base_urlv2 + "hosts/"
        server_response = self.sessionv2.get(cluster_url)
        return server_response.status_code ,json.loads(server_response.text)

    # Get all VMs in the cluster.
    def get_all_vm_info(self):

        cluster_url = self.base_urlv1 + "vms/"
        server_response = self.sessionv1.get(cluster_url)
        return server_response.status_code ,json.loads(server_response.text)
    
    # Get resource stats.
    def get_resource_stats(self,ent_type,uuid,resource):

        if (resource == "cpu"):
            metric = "hypervisor_cpu_usage_ppm"
        elif (resource == "memory"):
            if (ent_type == "host"):
                metric = "hypervisor_memory_usage_ppm"
            elif (ent_type == "vm"):
                metric = "guest.memory_usage_ppm"

        if ent_type == "vm":
            cluster_url = self.base_urlv1 + "vms/" + uuid + "/stats/?metrics=" + metric + "&startTimeInUsecs="
        elif ent_type == "host":
            cluster_url = self.base_urlv1 + "hosts/" + uuid + "/stats/?metrics=" + metric + "&startTimeInUsecs="
        else: 
            print("Selected wrong entity type...")
            print ("Existing")

        cur_time = int(time.time())
        start_time = cur_time - period
        # Now convert to usecs.
        cur_time = cur_time * 1000000
        start_time = start_time * 1000000

        # From: https://www.digitalformula.net/2018/api/vm-performance-stats-with-nutanix-rest-api/
        # https://10.133.16.50:9440/api/nutanix/v1/vms/3aa1699a-ec41-4037-aade-c73a9d14ed8c/stats/?metrics=hypervisor_cpu_usage_ppm&startTimeInUsecs=1524009660000000&endTimeInUsecs=1524096060000000&interval=30
 
        cluster_url += str(start_time) + "&" + "endTimeInUsecs=" + str(cur_time) + "&interval=30"
        server_response = self.sessionv1.get(cluster_url)
        return server_response.status_code ,json.loads(server_response.text)

    # Get storage container information.
    def get_ctr_info(self):

        cluster_url = self.base_urlv2 + "storage_containers/"
        server_response = self.sessionv2.get(cluster_url)
        return server_response.status_code ,json.loads(server_response.text)
    
    # Get cluster network information.
    def get_net_info(self):

        cluster_url = self.base_urlv2 + "networks/"
        server_response = self.sessionv2.get(cluster_url)
        return server_response.status_code ,json.loads(server_response.text)
    
    # Get cluster image information.
    def get_img_info(self):

        cluster_url = self.base_urlv2 + "images/"
        server_response = self.sessionv2.get(cluster_url)
        return server_response.status_code ,json.loads(server_response.text)

    # Post new image.
    def post_new_img(self,body):
        cluster_url = self.base_urlv08 + "images"
        server_response = self.sessionv08.post(cluster_url,data = json.dumps(body))
        return server_response.status_code ,json.loads(server_response.text)

    # Create new VM from image.
    def create_vm(self,body):
        cluster_url = self.base_urlv2 + "vms?include_vm_disk_config=true&include_vm_nic_config=true"
        print(json.dumps(body))
        server_response = self.sessionv2.post(cluster_url,data = json.dumps(body))
        return server_response.status_code ,json.loads(server_response.text)
    
    # Attach disk to VM.
    def attach_disk(self,body,vm_uuid):
        cluster_url = self.base_urlv2 + "vms/" + vm_uuid + "/disks/attach"
        print(json.dumps(body))
        server_response = self.sessionv2.post(cluster_url,data = json.dumps(body))
        return server_response.status_code ,json.loads(server_response.text)
    
    # VM power operataion
    def vm_powerop(self,body,vm_uuid):
        cluster_url = self.base_urlv2 + "vms/" + vm_uuid + "/set_power_state/"
        print(json.dumps(body))
        server_response = self.sessionv2.post(cluster_url,data = json.dumps(body))
        return server_response.status_code ,json.loads(server_response.text)

    def EntityMenu(self):
        print("\n\n")
        print("###############################################")
        print("What kind of operation do you want?")
        print("#################### MENU #################### ")
        print("Type 1: cluster info")
        print("Type 2: Host info")
        print("Type 3: Vm info")
        print("Type 4: Image info")
        print("Type 5: Container info")
        print("Type 6: Network info")
        print("Type 7: Upload new image from URL")
        print("Type 8: Create new VM without disk")
        print("Type 9: Attach disk to VM from disk Image")
        print("Type 10: VM Power on/off operation")
        print("\n")
        seLection = input()
        return seLection
    
# ========== DO NOT CHANGE ANYTHING ABOVE THIS LINE =====

def GetClusterDetail():
    if len(sys.argv) >= int(4):
        # Get Prism VIP username password from command line 
        ip = sys.argv[1]
        username = sys.argv[2]
        password = sys.argv[3]
    else:
        print("###############################################")
        print("You can also use '$python3 %s Prism_VIP username password' without interaction" %sys.argv[0])
        print("What's Prism VIP address? ")
        ip = input()
        if ipaddress.ip_address(ip):
            print ("You typed right ip format")
        else:
            print ("You typed wrong ip format")
            print ("Existing")   
        print("What is the Prism UI User which has admin role? ex)admin")
        username = input()
        password = getpass.getpass(prompt="What is the password for the Prism UI User?\n" , stream=None)
    return(ip,username,password)

def GetUUid():
    print("What's the entity(vm,host) uuid to check last 1 hr CPU/MEM performance?")
    uuid = input()
    return(uuid)