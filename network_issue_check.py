#! /usr/bin/env python
#
# Copyright (c) 2020 Nutanix Inc. All rights reserved.
#
# Author: taeho.choi@nutanix.com(Taeho Choi)

import re
import os.path
import sys
import subprocess
import time
sys.path.append(os.path.expanduser("~/bin"))

# Names of the ping stat(s) found inside the sysstats folder
DEFAULT_PING_HOSTS_FILE_NAME = "ping_hosts"
DEFAULT_PING_CVM_HOSTS_FILE_NAME = "ping_cvm_hosts"
DEFAULT_PING_GATEWAY_FILE_NAME = "ping_gateway"
DEFAULT_PING_CVMS_FILE_NAME = "ping_cvms"
LOGDIR = '/home/nutanix/data/logs/sysstats/'
TempDir = '/home/nutanix/tmp/'
LOGFILES = os.listdir(os.path.abspath(LOGDIR))
regex = re.compile(".+unreachable|TIMESTAMP.*")

def parse_log_file(filename):
    print(filename)
    os.chdir(LOGDIR)
    if filename == hostLog:
        outputFile = TempDir+"host"+".txt"
    elif filename == cvmHostLog:
        outputFile = TempDir+"cvm_host"+".txt"
    elif filename == gwLog:
        outputFile = TempDir+"gw"+".txt"
    elif filename == cvmLog:
        outputFile = TempDir+"cvm"+".txt"
    else:
        None
    print(outputFile)
    
    with open(outputFile, "w") as outp:     
        for i in filename:
                textfile = open(i, 'r')
                for line in textfile:
                        selected_line = regex.findall(line)
                        for item in selected_line:
                                outp.write("%s\n" % item)                                       
                textfile.close() 

def filter_log_file(filename):
    os.chdir(LOGDIR)
    if filename == hostLog:
        filtered_file = TempDir+"host"+".txt"
        outputFile = TempDir+"host_unreachable"+".txt"
    elif filename == cvmHostLog:
        filtered_file = TempDir+"cvm_host"+".txt"
        outputFile = TempDir+"cvm_host_unreachable"+".txt"
    elif filename == gwLog:
        filtered_file = TempDir+"gw"+".txt"
        outputFile = TempDir+"gw_unreachable"+".txt"
    elif filename == cvmLog:
        filtered_file = TempDir+"cvm"+".txt"
        outputFile = TempDir+"cvm_unreachable"+".txt"
    else:
        None
    with open(outputFile, "w+") as f:
        subprocess.Popen('grep -B1 unreachable %s' %filtered_file, shell=True, universal_newlines = True, stderr=subprocess.STDOUT, stdout=f)
    time.sleep(2)
    os.remove(filtered_file)

if __name__ == "__main__":
    hostLog = [file for file in LOGFILES if file.startswith(DEFAULT_PING_HOSTS_FILE_NAME)]
    cvmHostLog = [file for file in LOGFILES if file.startswith(DEFAULT_PING_CVM_HOSTS_FILE_NAME)]
    gwLog = [file for file in LOGFILES if file.startswith(DEFAULT_PING_GATEWAY_FILE_NAME)]
    cvmLog = [file for file in LOGFILES if file.startswith(DEFAULT_PING_CVMS_FILE_NAME)]

for i in [hostLog,cvmHostLog,gwLog,cvmLog]:
        parse_log_file(i)
        filter_log_file(i)         