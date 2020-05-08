import pprint
import sys
import inspect
import json
import os
import requests
import ipaddress
from datetime import datetime
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
from requests.auth import HTTPBasicAuth
from getpass import getpass
from requests.exceptions import HTTPError
from os import system, name
username = str()
password = str()
url=":9440/PrismGateway/services/rest/v2.0/"

def select_cluster():
    print ">>>> Type Prism UI VIP address >>>>"
    VIP = str(raw_input())
    if ipaddress.ip_address(unicode(VIP)):
       print "You typed right ip  format"
    else:
      print "You typed wrong ip format"
      print "Existing"
      exit

    lab1="https://" + VIP
    print(lab1)
    print ">>>> Select your cluster >>>>"
    print ""
    print "1> Your cluster "
    print ""
    answer = input("selection : ")
    if answer == int(1):
        cluster = str(lab1)
        clustername = str("customer_cluster")
    else:
        print "Wrong option"
    return cluster, clustername

class vm_operation:
    def __init__(self, username, password, cluster):
        print ">>>> Type Prism UI User which has admin role >>>>"
        username = str(raw_input())
        print ">>>> Type Prism UI User which has admin password >>>>"
        password  = str(raw_input())
        self.username = username
        self.password = password
        self.cluster = cluster
        self.fullpath = self.cluster + url
        self.fullpath3 = self.cluster + url

    def select_cluster(self):
        answer = input("selection : ")
        if answer == int(1):
            cluster = str(lab1)
            clustername = str("customer_cluster")
        else:
            print "wrong option"
            fullpath=self.cluster + url
        #fullpath2=selfcluster + url2
        return fullpath, fullpath2

    def listdisk(self):
        print
        print "........... Listing all of disk in %s" %clustername
        subpath='/disks'
        response=requests.get(self.fullpath3 + subpath, headers={'Accept': 'application/json'}, verify=False, auth=HTTPBasicAuth(self.username, self.password))
        data_convert=json.loads(response.text)
        disk_count=len(data_convert['entities'])
        print ""
        print ""
        print "Total number of disks in this cluster : %s" %disk_count
        diskinfo={}
        for i in range(disk_count):
            disk_list=data_convert['entities'][i]['disk_hardware_config']['mount_path']
            disk_serial=data_convert['entities'][i]['disk_hardware_config']['serial_number']
            print "%s || disk mountpath & serial number: " %i
            print disk_list
            print disk_serial
            print "======================"
            print ""
            print ""

    def menu(self):
        print ""
        print ""
        print "Menu"
        print "1> list disk info in cluster"
        print "2> exit"
        print ""
        choice = input("Answer: ")
        print ""
        return choice

if __name__ == '__main__':
    while True:
        cluster, clustername = select_cluster()
        vmops=vm_operation(str(username), str(password), str(cluster))
        menu_choice=vmops.menu()
        if menu_choice == 1:
            vmops.listdisk()
        elif menu_choice == 2:
            exit
        else:
            print("Good Bye")
            exit
