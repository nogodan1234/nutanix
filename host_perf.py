#!/usr/bin/env python3

#Script Name : host_perf.py
#Script Purpose or Overview 
# - this script will show last 1 hr entity(host_perf) "controller_avg_io_latency_usecs "performance data - host interactive option as well as argv option.
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
#  

import sys
import requests
import urllib.request
import clusterconfig as C
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import json
import time
from datetime import datetime
import xlsxwriter


def printHostStats(hostname,hostStatsDict):
    # Create a filename based on current timestamp and initialise worksheet
    now = datetime.now()
    dt_string = now.strftime("%d-%m-%y_%H-%M-%S")
    fileName = hostname+"_perf_report_" + dt_string + ".xlsx"
    print(fileName)
    workbook = xlsxwriter.Workbook(fileName)
    worksheet = workbook.add_worksheet()
    bold = workbook.add_format({'bold': True})

    # Add data headers or titles for the metrics
    worksheet.write('A1', 'Hostname', bold)
    worksheet.write('B1', 'Metric name', bold)
    worksheet.write('C1', 'Interval(sec)', bold)
    worksheet.write('D1', 'Starttime', bold)
    worksheet.write('E1', 'Value', bold)

    # Set starting row and column on worksheet

    worksheet.write(1, 0, hostname)
    worksheet.write(1, 1, hostStatsDict['statsSpecificResponses'][0]['metric'])
    worksheet.write(1, 2, hostStatsDict['statsSpecificResponses'][0]['intervalInSecs'])
    localtime = int(hostStatsDict['statsSpecificResponses'][0]['startTimeInUsecs'])/1000000
    worksheet.write(1, 3, time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(localtime)))
    
    row=1
    col=4
    for i in hostStatsDict['statsSpecificResponses'][0]['values']:
        worksheet.write(row, col, i)
        row += 1
    workbook.close()

if __name__ == "__main__":
    cluster = C.GetClusterDetail()  
    ip = cluster[0]
    username = cluster[1]
    password = cluster[2]  

    mycluster = C.my_api(ip,username,password)
    #print all hosts and name to user
    print("This is list of hosts in your cluster...\n")
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

    period=3600

    for n in all_hosts["entities"]:
        print("Host name: " + n["name"].ljust(maxfield))
        print("Collecting controller_avg_io_latency_usecs stats from each host ...")
        cluster_url = mycluster.base_urlv1 + "hosts/" + n["uuid"] + "/stats/?metrics=" + "controller_avg_io_latency_usecs" + "&startTimeInUsecs="
        cur_time = int(time.time())
        start_time = cur_time - period
        # Now convert to usecs.
        cur_time = cur_time * 1000000
        start_time = start_time * 1000000
        cluster_url += str(start_time) + "&" + "endTimeInUsecs=" + str(cur_time) + "&interval=30"
        server_response = mycluster.sessionv1.get(cluster_url)
        print(server_response.status_code)
        print(json.loads(server_response.text))
        printHostStats(n["name"],json.loads(server_response.text))

