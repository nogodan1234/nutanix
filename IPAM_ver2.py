import getpass
import requests
import json
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def ipRange(start_ip, end_ip):
    start = list(map(int, start_ip.split(".")))
    end = list(map(int, end_ip.split(".")))
    temp = start
    ip_range = []

    ip_range.append(start_ip)
    while temp != end:
        start[3] += 1
        for i in (3, 2, 1):
            if temp[i] == 256:
                temp[i] = 0
                temp[i - 1] += 1
        ip_range.append(".".join(map(str, temp)))

    return ip_range

#from colorama import Fore
print("***************************************************************************************************************")
print("This script will help you in Discovering your IPAM IP address allocations on your AHV Cluster")
print('***************************************************************************************************************')
print('\n\n\n')
cluster_IP = input("Please enter the cluster management IP: ")
userName = input("Username: ")
passWord = input("Password: ")

network_list_url = ("https://" + str(cluster_IP)+":9440/PrismGateway/services/rest/v2.0/networks")

s = requests.Session()
s.auth = (userName,passWord)
s.headers.update({'Content-Type': 'application/json; charset=utf-8'})
network_Data = s.get(network_list_url, verify=False).json()


print("Those networks exist on the cluster ")
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
for n in network_Data["entities"]:
	print("Network Name "+n["name"]+" with vlan id " +str(n["vlan_id"])+ " and its UUID is " + n["uuid"] )
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
print("\n\n")
UUID = input("Please copy and paste the UUID of the intended network for inspection: ")
Specific_network_url = (network_list_url + "/" + UUID)
network_IPs_list_url = (Specific_network_url + "/" + "addresses")
Specific_network_details = s.get(Specific_network_url, verify=False).json()
Network_IPs_details = s.get(network_IPs_list_url, verify=False).json()
print ("\nHere are the details of your selected network: \n")
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
print("Network Name:  " + Specific_network_details["name"]+"\n" )
print("VLAN ID:  " + str(Specific_network_details["vlan_id"])+"\n" )
if Specific_network_details["ip_config"]["pool"] == []:
    print("This is an unmanaged network, IPAM is not available for this network,no further information to present for this network. \n")
else :
    print("Network Address:  " + Specific_network_details["ip_config"]["network_address"] + "\n")
    print("Prefix Length:  " + str(Specific_network_details["ip_config"]["prefix_length"]) + "\n")
    print("Default Gateway:  " + Specific_network_details["ip_config"]["default_gateway"] + "\n")
    #print("DNS Server:  " + Specific_network_details["ip_config"]["dhcp_options"]["domain_name_servers"] + "\n")
    #print("Domain Name:  " + Specific_network_details["ip_config"]["dhcp_options"]["domain_name"] + "\n")
    print("The number of configured IP Pools: " + str(len(Specific_network_details["ip_config"]["pool"])))
    IPRANGE=[]
    for i in range(1,len(Specific_network_details["ip_config"]["pool"])+1):
        IP_Range=Specific_network_details["ip_config"]["pool"][i-1]["range"]
        SPltted_range=IP_Range.split()
        Starting_IP=(SPltted_range[0])
        Ending_IP = (SPltted_range[1])
        print("Pool #"+str(i)+ " starts with "+Starting_IP+" and ends with "+Ending_IP )
        ip_range = ipRange(Starting_IP, Ending_IP)
        IPRANGE=IPRANGE + ip_range
    print("The total number of IPs configured in the pool(s): "+str(len(IPRANGE)))
    print("Total number of allocated IPs: "+ str(Network_IPs_details["metadata"]["total_entities"]))
    print("Total available IPs in the pool(s): "+ str(len(IPRANGE)-Network_IPs_details["metadata"]["total_entities"]))
    print("\n")

    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^") 
    print("Detail usage of the ip")
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^") 
    for n in Network_IPs_details["entities"]:
        vm_list_url = ("https://" + str(cluster_IP)+":9440/api/nutanix/v2.0/vms/"+str(n["entity_uuid"]))
        vm_Data= s.get(vm_list_url, verify=False).json()
        print("VM name %s" %vm_Data["name"] + " is using ip address " + str(n["ip_address"])+ " with mac_address " + str(n["mac_address"]) + " from this pool" )
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
    print("\n")

    if len(IPRANGE)-Network_IPs_details["metadata"]["total_entities"] > 0:
        print("You still have available IPs in the Pool(s). Don't worry.")
    else:
        print("You ran out of IPs. You need to expand the pool")