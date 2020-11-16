echo "#############################################"											                                                        | tee -a ~/tmp/node_config_failure.txt
echo "node config failure with slow network  "										                                                                    | tee -a ~/tmp/node_config_failure.txt
echo "#############################################"											                                                        | tee -a ~/tmp/node_config_failure.txt
rg -z "Created node pool" -g "karbon_core.*"												                                                            | tee -a ~/tmp/node_config_failure.txt
rg -z "executing: docker pull quay.io/karbon" -g "karbon_core.*"								                                                        | tee -a ~/tmp/node_config_failure.txt
rg -z "Failed to deploy and verify worker node(s): failed to deploy worker nodes" -g "karbon_core.*"												    | tee -a ~/tmp/node_config_failure.txt
rg -z 'Error seen in configuring worker node: "Operation timed out"' -g "karbon_core.*"                                                                 | tee -a ~/tmp/node_config_failure.txt

#/home/docker/karbon_core/karbon_core_config.json
                # "image": "karbon-core:v2.1.1",
                # "entry_point": [
                #         "/karbon",
                #         "-debug=true",
                #         "-v=4",
                #         "-logtostderr"
                #         "-ssh-timeout=10m"
                # ],

echo "#############################################"											                                                        | tee -a ~/tmp/KB9610_KRBN3275.txt
echo "Karbon UI - Internal server error: KB 9610 "										                                                                | tee -a ~/tmp/KB9610_KRBN3275.txt
echo "#############################################"											                                                        | tee -a ~/tmp/KB9610_KRBN3275.txt
rg -z "/etc/ssl/KarbonCoreService.key: permission denied" -g "karbon_core.*"												                            | tee -a ~/tmp/KB9610_KRBN3275.txt

echo "#############################################"											                                                        | tee -a ~/tmp/oncall-7564.txt
echo "Karbon upgrade error - Oncall 7564, ergon task stuck "										                                                    | tee -a ~/tmp/oncall-7564.txt
echo "#############################################"											                                                        | tee -a ~/tmp/oncall-7564.txt
rg -z "to get the cluster status with error Failure in IDF operation: Entity not found" -g "karbon_core.*"												| tee -a ~/tmp/oncall-7564.txt
rg -z "Failed to get cluster config status " -g "karbon_core.*"												                                            | tee -a ~/tmp/oncall-7564.txt

echo "#############################################"											                                                        | tee -a ~/tmp/upgrade_node_label.txt
echo "Check master/worker node label during the upgrade"										                                                        | tee -a ~/tmp/upgrade_node_label.txt
echo "#############################################"											                                                        | tee -a ~/tmp/upgrade_node_label.txt
for i in $(kubectl get node  | grep -v NAME | awk '{print $1}'); do echo "## checking labels of all nodes ##"; echo "label of node $i" ; kubectl get node $i -o jsonpath='{.metadata.labels}' ;done                   | tee -a ~/tmp/upgrade_node_label.txt

echo "#############################################"											                                                        | tee -a ~/tmp/krbn3519.txt
echo "Multiple AZ Karbon core crash - KRBN-3519 "										                                                                | tee -a ~/tmp/krbn3519.txt
echo "#############################################"											                                                        | tee -a ~/tmp/krbn3519.txt
rg -z "Failed to authenticate GetVersions(): unknown error" -g "karbon_core.*"												                            | tee -a ~/tmp/krbn3519.txt

echo "#############################################"											                                                        | tee -a ~/tmp/CSI_log.txt
echo "CSI log collector sh"										                                                                                        | tee -a ~/tmp/CSI_log.txt
echo "#############################################"											                                                        | tee -a ~/tmp/CSI_log.txt
#3rd party CSI installation
for i in $(kubectl get pod -n kube-system | grep csi-node | awk '{print$1}') ; do kubectl logs $i driver-registrar -n kube-system ;done > driver-registrar.txt
for i in $(kubectl get pod -n kube-system | grep csi-node | awk '{print$1}') ; do kubectl logs $i csi-node-ntnx-plugin -n kube-system ;done > csi-node-ntnx-plugin.txt

#Karbon CSI installation
for i in $(kubectl get pod -n ntnx-system | grep csi-node | awk '{print$1}') ; do kubectl logs $i driver-registrar -n ntnx-system ;done > driver-registrar.txt
for i in $(kubectl get pod -n ntnx-system | grep csi-node | awk '{print$1}') ; do kubectl logs $i csi-node-ntnx-plugin -n ntnx-system ;done > csi-node-ntnx-plugin.txt

#echo "KB 7616"
#from wk "sudo systemctl status kubelet-worker.service"
#from wk "sudo systemctl restart kubelet-worker.service | grep `docker pull`