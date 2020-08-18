#!/usr/bin/bash

echo "#############################################"
echo " What is the timeslot that you want to analize? "
echo " Please type with Aug 17 23:48 2020 format"
echo "#############################################"
read TOI

echo "#############################################"
echo "This is acropolos log data format"
acro_data=`date -d"${TOI}"  +'%Y-%m-%d %H:%M'`
echo $acro_data

echo "#############################################"
echo "This is stargate log data format"
star_data=`date -d"${TOI}"  +'%m%d %H:%M'`
echo $star_data

echo "#############################################"
echo "This is dmesg log data format"
dmesg_data=`date -d"${TOI}"  +'%b %d %H:%M'`
echo $dmesg_data

echo "#############################################"
echo "This is cvm dmesg log data format"
cvm_dmsg_data=`date -d"${TOI}"  +'%Y-%m-%dT%H:%M'`
echo $cvm_dmsg_data

echo "#############################################"
echo "This is ping log data format"
ping_data=`date -d"${TOI}"  +'%m/%d/%Y %r'`
echo $ping_data