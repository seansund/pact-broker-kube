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

#region="us-south"
#namespaceRegion="ng"
#clusterName="mycluster"
#registryNamespace="pact-broker"
tagBase=""
appName="pactbroker"
appTag="1"

if [[ -z "$KUBECONFIG" ]]; then
  echo -e "\033[1;31mError: KUBECONFIG environment has not been set\033[0m. The variable can be set with the following:"
  echo -e "ibmcloud cs cluster-config --cluster ${clusterName} --export > ./.kubeconfig"
  echo -e "source ./.kubeconfig"
  exit 1
fi
#
#if [[ -z "$1" ]]; then
#  echo -e "\033[1;31mError: Please pass the base for the tag name (e.g. registry.ng.bluemix.net/{registryNamespace}) as the first arg.\033[0m"
#  echo -e "Example: ./deploy-kube.sh registry.ng.bluemix.net/myregistry"
#  exit 1
#else
#  tagBase="$1"
#fi
#
#imageDir=$(dirname "$0")
#cd ${imageDir}

#
#
## Check if `ibmcloud` cli tool is installed
#command -v ibmcloud >/dev/null 2>&1 || {
#  echo >&2 -e "\033[1;31mibmcloud cli not installed.\033[0m"
#  echo -e "Please install ibmcloud cli to use deploy script by running: \033[1;37mcurl -sL https://ibm.biz/idt-installer | bash\033[0m"
#  exit 1;
#}
#
## Check if logged in
#echo -e "Verifying targeted IBM Cloud cluster: ${clusterName}"
#ibmcloud ks workers ${clusterName} 1>/dev/null 2>/dev/null
#if [[ $? -eq 1 ]]; then
#  echo -e "\033[1;31mMake sure you're logged in to the ibmclound cli using ibmcloud login, or ibmcloud login --help for more info.\033[0m"
#  echo -e 'E.g 1: ibmcloud login'
#  echo -e 'E.g 2: ibmcloud login -a "https://api.ng.bluemix.net"'
#  echo -e "E.g 3: ibmcloud login --help"
#  exit 1;
#fi
#
#echo -e "\nSetting the Kubernetes service region: \033[1;34m${region}\033[0m"
#ibmcloud cs region-set ${region}
#
#echo -e "\nSetting the KUBECONFIG for cluster: \033[1;34m${clusterName}\033[0m"
#ibmcloud cs cluster-config --cluster ${clusterName} --export > ./.kubeconfig
#
#source ./.kubeconfig
#
#echo -e "  KUBECONFIG=\033[1;37m${KUBECONFIG}\033[0m"
#
#echo -e "\nAdding the registry namespace: \033[1;34m${registryNamespace}\033[0m"
#ibmcloud cr namespace-add ${registryNamespace} 1>/dev/null 2>/dev/null
#
#if [[ ! $? -eq 0 ]]; then
#  echo -e "  \033[1;31mError adding registry namespace: ${registryNamespace}\033[0m"
#fi
#tagBase="registry.${namespaceRegion}.bluemix.net/${registryNamespace}"

#tagName="${tagBase}/${appName}:${appTag}"
tagName="dius/pact-broker"
#
#echo -e "\nBuilding docker image: \033[1;34m${tagName}\033[0m"
#docker build -t ${tagName} .
#
#echo -e "\nLogging into container registry"
#ibmcloud cr login 1>/dev/null 2>/dev/null
#
#echo -e "\nRemoving the old image: \033[1;34m${tagName}\033[0m"
#ibmcloud cr image-rm ${tagName} 1>/dev/null 2>/dev/null
#
#sleep 3
#
#echo -e "\nPushing docker image: \033[1;34m${tagName}\033[0m"
#docker push ${tagName}

deploymentName=${appName}-deployment
kubectl delete deployment/${deploymentName} 1>/dev/null 2>/dev/null

echo -e "\nRunning kubernetes deployment: \033[1;34m${deploymentName}\033[0m for image \033[1;34m${tagName}\033[0m"
kubectl run ${deploymentName} --image=${tagName} --port=80 \
  --env="PACT_BROKER_DATABASE_ADAPTER=sqlite" \
  --env="PACT_BROKER_DATABASE_NAME=pactbroker.sqlite"

serviceName=${appName}-http-service
kubectl delete service/${serviceName} 1>/dev/null 2>/dev/null

echo -e "\nExposing deployment port \033[1;34m80\033[0m as service \033[1;34m${serviceName}\033[0m"
kubectl expose deployment/${deploymentName} --type=NodePort --port=80 --name=${serviceName} --target-port=80
#kubectl create service nodeport ${serviceName} --tcp=80:80 --node-port=30080

publicIP=$(ibmcloud ks workers mycluster | grep -v "^OK" | grep -v "^ID" | sed "s/^[0-9a-z-]* *\([0-9.]*\) *.*/\1/g")
#publicPort="80"
kubectl describe service ${serviceName}
publicPort=$(kubectl describe service ${serviceName} | grep "NodePort:" | sed "s~[^0-9]*\([0-9]*\).*~\1~g")

echo -e "\nApplication deployed. Access the application via \033[1;34mhttp://${publicIP}:${publicPort}/\033[0m\n"
