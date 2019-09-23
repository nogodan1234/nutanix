# Nutanix script repo by taeho choi

Nutanix useful script repo by taeho choi

## Getting Started

These scripts are created with intention to help  Nutanix SRE(Site Reliabilty Engineer), SE(System Engineer) and administrator to manage/deploy/config/troubleshoot Nutanix HCI environment.

### Prerequisites

Need to understand basic bash script syntax and Nutanix cluster components.

```
Prims Element? Data service ip?
```

### Installing
Just download with git clone then run the shell script with sh command from any linux base system - Mac,Centos,Ubuntu etc
ex) $sh int_auto_script.sh

## Running the tests

1. init_auto_script.sh
This script will ask Prism Element IP to configure cluster setting, 

Prerequistes
- Updated auto_script.sh base on your environment and located in same directory
  ex) Network pool/vlan configuration,ntp,data service ip etc

- nutanix user ssh public key must exist with Prism Element via API or Prism Console
  API: https://www.nutanix.dev/reference/prism_element/v2/api/cluster/post-cluster-public-keys-addpublickey
  Prism Console: https://portal.nutanix.com/#/page/docs/details?targetId=Nutanix-Security-Guide-v511:wc-security-cluster-lockdown-wc-t.html

2. nutanix_home_clean.sh
This is for /home/nutanix gaubage clean up which is addressed on KB 1540
You can just download this script to cvm which complains about /home/nutanix space then run it will clean up delet safe files and directories
http://portal.nutanix.com/kb/1540
Please see more detail on readme_nutanix_home_clean.doc in this repo, how to use

3. taeho_rca.sh
This is for nutanix sre to help narrow down issue with known log signature, this need rg(recursive grep) pkg installed already and will parse ncc log bundle base on known issues.

## Authors

* **Taeho Choi** - *Initial work* - [PurpleBooth](https://github.com/nogodan1234/nutanix)

See also the list of [contributors](https://github.com/nogodan1234/nutanix/contributors) who participated in this project.

## License

This project is licensed under the MIT License

## Acknowledgments

* Nutanix is not officially tested on these scripts nor provide supports on these.
* All responsibilies to use this scripts are on each user.
* etc
# nutanix
