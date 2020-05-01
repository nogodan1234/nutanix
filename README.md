# Some useful Nutanix scripts 

## Getting Started

These scripts are created with intention to help  Nutanix SRE(Site Reliabilty Engineer), SE(System Engineer) and administrator to manage/deploy/config/troubleshoot Nutanix HCI environment.

### Prerequisites

Need to understand basic bash script syntax and Nutanix cluster components.

```
Prims Element? Data service IP?
```

### How to run each script !
Just download with git clone then run the shell script with sh command from any linux base system - Mac,Centos,Ubuntu etc
```
ex) $sh int_auto_script.sh
```

### Detail on each script
# 
1. init_auto_script.sh

This script will ask Prism Element IP to congfigure various information by one command. 

Prerequistes
- Updated `auto_script.sh` base on your environment and located in same directory
  	
  	ex) Network pool/vlan configuration,ntp,data service ip etc

- nutanix user ssh public key must exist with Prism Element via API or Prism Console

  	API: https://www.nutanix.dev/reference/prism_element/v2/api/cluster/post-cluster-public-keys-addpublickey
  	
  	Prism Console: https://portal.nutanix.com/#/page/docs/details?targetId=Nutanix-Security-Guide-v511:wc-security-cluster-lockdown-wc-t.html

# 
2. nutanix_home_clean.sh

	This is for `/home/nutanix` garbage files clean up which is addressed on Nutanix KB 1540

	You can just download this script to cvm which complains about /home/nutanix space then run it will clean up delet-safe files and directories

	http://portal.nutanix.com/kb/1540

	Please see more detail on readme_nutanix_home_clean.doc in this repo, how to use

# 
3. taeho_rca.sh

	This is for nutanix sre to help narrow down issue with known log signature, this need rg(recursive grep) pkg installed already and will parse ncc log bundle base on known issues.
# 
## Authors

* **Taeho Choi** - (https://github.com/nogodan1234)

See also the list of [contributors](https://github.com/nogodan1234/nutanix/contributors) who participated in this project.

## License

This project is licensed under the MIT License

## Acknowledgments

* Nutanix does not provide support for these scripts.
* Nutanix has not officially tested these scripts.
* All responsibilies to use this scripts are on each individual.

