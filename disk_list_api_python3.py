#
import pprint
import sys
import inspect
import json
import os
import requests
import ipaddress
import time
from datetime import datetime
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
from requests.auth import HTTPBasicAuth
from getpass import getpass
from requests.exceptions import HTTPError
from os import system, name

url=":9440/PrismGateway/services/rest/v2.0/"
username=str()
password=str()

def select_cluster():
    print (">>>> Type Prism UI VIP address >>>>")
    VIP = input()
    if ipaddress.ip_address(VIP):
       print ("You typed right ip  format")
    else:
      print ("You typed wrong ip format")
      print ("Existing")
      exit

    lab1="https://" + VIP
    print(lab1)
    cluster = str(lab1)
    return cluster

class vm_operation:
    def __init__(self, username, password, cluster):
        print (">>>> Type Prism UI User which has admin role >>>>")
        name = input()
        print (">>>> Type Prism UI User which has admin password >>>>")
        passwd  = input()
        self.username = name
        self.password = passwd
        self.cluster = cluster
        self.fullpath = self.cluster + url

    def listdisk(self):
        print ("........... Listing all of disk in %s" %cluster)
        subpath='/disks'
        response=requests.get(self.fullpath + subpath, headers={'Accept': 'application/json'}, verify=False, auth=HTTPBasicAuth(self.username, self.password))
        data_convert=json.loads(response.text)
        disk_count=len(data_convert['entities'])
 
        print ("################################################### ")
        print ("Total number of disks in this cluster : %s" %disk_count)
        diskinfo={}
        for i in range(disk_count):
            disk_list=data_convert['entities'][i]['disk_hardware_config']['mount_path']
            disk_serial=data_convert['entities'][i]['disk_hardware_config']['serial_number']
            print ("%s || disk mountpath & serial number: " %i)
            print (disk_list)
            print (disk_serial)
            print ("################################################")
            print (" ")

    def menu(self):
        print ("################################################### ")
        print ("Menu")
        print ("1: list disk info in cluster")
        print ("Any other keys to exit")
        print ("################################################### ")
        choice = input("Answer: ")
        print ("################################################### ")
        return choice

if __name__ == '__main__':
        cluster = select_cluster()
        vmops=vm_operation(str(username), str(password), str(cluster))
        menu_choice=vmops.menu()
        if menu_choice == str(1):
            vmops.listdisk()
        else:
            print("Good Bye")
            exit
