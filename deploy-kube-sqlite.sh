#!/usr/bin/env bash

# console echo colors
#  \033[1;31m red
#  \033[1;32m green
#  \033[1;33m amber
#  \033[1;34m blue
#  \033[1;35m purple
#  \033[1;36m light blue
#  \033[1;37m grey
#  \033[1;38m black

# curl -sL https://ibm.biz/idt-installer | bash
# ibmcloud plugin install container-registry -r Bluemix

region="us-south"
namespaceRegion="ng"
clusterName="ct-seats-dev-02"
registryNamespace="pact-broker"

if [[ -z "$1" ]]; then
  echo -e "\033[1;31mError: Please pass the cluster name (e.g. dev, tst, prd) as the first arg.\033[0m"
  echo -e "Example: ./deploy-kube.sh dev-cluster"
  echo -e "Example: ./deploy-kube.sh tst-cluster"
  exit 1
else
  clusterName="$1"
fi


# Check if `ibmcloud` cli tool is installed
command -v ibmcloud >/dev/null 2>&1 || {
  echo >&2 -e "\033[1;31mibmcloud cli not installed.\033[0m"
  echo -e "Please install ibmcloud cli to use deploy script by running: \033[1;37mcurl -sL https://ibm.biz/idt-installer | bash\033[0m"
  exit 1;
}

# Check if logged in
echo -e "Verifying targeted IBM Cloud cluster: ${clusterName}"
ibmcloud ks workers ${clusterName} 1>/dev/null 2>/dev/null
if [[ $? -eq 1 ]]; then
  echo -e "\033[1;31mMake sure you're logged in to the ibmclound cli using ibmcloud login, or ibmcloud login --help for more info.\033[0m"
  echo -e 'E.g 1: ibmcloud login'
  echo -e 'E.g 2: ibmcloud login -a "https://api.ng.bluemix.net"'
  echo -e "E.g 3: ibmcloud login --help"
  exit 1;
fi

echo -e "\nSetting the Kubernetes service region: \033[1;34m${region}\033[0m"
ibmcloud cs region-set ${region}

echo -e "\nSetting the KUBECONFIG for cluster: \033[1;34m${clusterName}\033[0m"
ibmcloud cs cluster-config --cluster ${clusterName} --export > ./.kubeconfig

source ./.kubeconfig

echo -e "  KUBECONFIG=\033[1;37m${KUBECONFIG}\033[0m"

echo -e "\nAdding the registry namespace: \033[1;34m${registryNamespace}\033[0m"
ibmcloud cr namespace-add ${registryNamespace} 1>/dev/null 2>/dev/null

if [[ ! $? -eq 0 ]]; then
  echo -e "  \033[1;31mError adding registry namespace: ${registryNamespace}\033[0m"
fi

tagBase="registry.${namespaceRegion}.bluemix.net/${registryNamespace}"

./pact-broker/deploy-kube-sqlite.sh
