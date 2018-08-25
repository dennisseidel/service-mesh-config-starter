#!/bin/bash
set -x

# move to script folder
cd $(dirname $0)
echo $(pwd)

if ! [ -x "$(command -v brew)" ]; then
  echo 'Info: brew is not installed. Installing it now:'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
if ! [ -x "$(command -v docker)" ]; then 
  echo 'Info: docker is not installed. Installing it now:'
  brew cask install docker
fi
if ! [ -x "$(command -v helm)" ]; then
    echo 'Info: helm is not installed. Installing it now:'
    brew install kubernetes-helm
fi

if [ "$KUBE_ENV" = "osx" ] 
then
  if ! [ -x "$(command -v minikube)" ]; then
    echo 'Info: minikube is not installed. Installing it now:'
    brew cask install minikube
  fi
  if ! [ -f /usr/local/bin/docker-machine-driver-hyperkit ]; then
    echo 'Info: hyperkit is not installed. Installing it now:'
    curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit \
    && chmod +x docker-machine-driver-hyperkit \
    && sudo mv docker-machine-driver-hyperkit /usr/local/bin/ \
    && sudo chown root:wheel /usr/local/bin/docker-machine-driver-hyperkit \
    && sudo chmod u+s /usr/local/bin/docker-machine-driver-hyperkit
  fi

  clustercheck=$(kubectl --request-timeout=5s get services || true)
  if [[ $clustercheck != *"kubernetes"* ]]; then
    minikube start --memory=8192 --cpus=4 --vm-driver=hyperkit -b=localkube \
    --extra-config=apiserver.Authorization.Mode=RBAC \
    --extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
    --extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
    --kubernetes-version=v1.10.0 \
    --extra-config=apiserver.ServiceNodePortRange=79-36000
    sleep 5 
    kubectl apply ../config/templates/rbac-istiosetup.yaml
    kubectl label namespace default istio-injection=enabled
    kubectl get namespace -L istio-injection
  fi
  # isntallation https://istio.io/docs/setup/kubernetes/quick-start/#installation-steps
  ISTIO_DIR="$(find . -type d -name istio-*.*  -exec basename {} \;)"
  if [[ $ISTIO_DIR != *"istio"* ]]; then 
    curl -L https://git.io/getLatestIstio | sh -
    ISTIO_DIR="$(find . -type d -name istio-*.*  -exec basename {} \;)"
  else 
    echo WARNING: $ISTIO_DIR allready exists
  fi
  cd $ISTIO_DIR 
  export PATH=$PWD/bin:$PATH
  kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
  kubectl create -f install/kubernetes/helm/helm-service-account.yaml
  helm init --wait --service-account tiller
  helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
  --set global.proxy.includeIPRanges="" \
  --set global.crds=false \
  --set tracing.enabled=true \
  --set gateways.istio-ingressgateway.type=NodePort \
  --set gateways.istio-ingressgateway.ports[0].port=80,gateways.istio-ingressgateway.ports[0].name=http2,gateways.istio-ingressgateway.ports[0].nodePort=80 \
  --set gateways.istio-ingressgateway.ports[1].port=443,gateways.istio-ingressgateway.ports[1].name=https,gateways.istio-ingressgateway.ports[1].nodePort=443 \
  --set gateways.istio-ingressgateway.ports[2].port=31400,gateways.istio-ingressgateway.ports[2].name=tcp,gateways.istio-ingressgateway.ports[2].nodePort=31400
  echo "check that the following services exist: istio-pilot, istio-ingressgateway, istio-policy, istio-telemetry, prometheus and, optionally, istio-sidecar-injector"
  kubectl get svc -n istio-system
  echo "check that the following pods exist: istio-pilot-*, istio-ingressgateway-*, istio-egressgateway-*, istio-policy-*, istio-telemtry-*, istio-citadel-*, prometheus-* and, optionally, istio-sidecar-injector-*"
  kubectl get pods -n istio-system
  INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
  INGRESS_HOST=$(minikube ip)
  echo $INGRESS_HOST:$INGRESS_PORT
fi

if [ "$KUBE_ENV" = "gcp" ] 
then
  if ! [ -x "$(command -v terraform)" ]; then
    echo 'Info: terraform is not installed. Installing it now:'
    brew install terraform
  fi
  cd ../config/templates/gke && terraform init
  if [ -x "$(command -v 1lpass)" ]; then
    terraform apply -var username=$(lpass show gcp-kubernetes --username) -var password=$(lpass show gcp-kubernetes --password)
  else
    terraform apply
  fi
  echo "GOOGLE IS BILLING YOU NOW UNTIL YOU DESTROY THE CLUSTER WITH: cd gke && terraform destroy"
  gcloud container clusters get-credentials d10l-plattform-cluster  --zone us-central1-a --project trusty-acre-156607
  kubectl cluster-info

  kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)
  
  kubectl label namespace default istio-injection=enabled
  kubectl get namespace -L istio-injection

  cd ..
  # isntallation https://istio.io/docs/setup/kubernetes/quick-start/#installation-steps
  ISTIO_DIR="$(find . -type d -name istio-*.*  -exec basename {} \;)"
  if [[ $ISTIO_DIR != *"istio"* ]]; then 
    curl -L https://git.io/getLatestIstio | sh -
    ISTIO_DIR="$(find . -type d -name istio-*.*  -exec basename {} \;)"
  else 
    echo WARNING: $ISTIO_DIR allready exists
  fi
  cd $ISTIO_DIR 
  export PATH=$PWD/bin:$PATH
  kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
  kubectl create -f install/kubernetes/helm/helm-service-account.yaml
  helm init --wait --service-account tiller
  helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
  --set global.proxy.includeIPRanges="" \
  --set global.crds=false \
  --set tracing.enabled=true
  echo "check that the following services exist: istio-pilot, istio-ingressgateway, istio-policy, istio-telemetry, prometheus and, optionally, istio-sidecar-injector"
  kubectl get svc -n istio-system
  echo "check that the following pods exist: istio-pilot-*, istio-ingressgateway-*, istio-egressgateway-*, istio-policy-*, istio-telemtry-*, istio-citadel-*, prometheus-* and, optionally, istio-sidecar-injector-*"
  kubectl get pods -n istio-system
  export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  echo $GATEWAY_URL

  #check where gcloud is installed 
  #which gcloud

  # Set Google Application Credentials
  #echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > ${HOME}/gcloud-service-key.json && export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/gcloud-service-key.json"

  # Authenticate the gcloud tool
  #gcloud auth activate-service-account --key-file=${HOME}/gcloud-service-key.json
  #gcloud config set project $GCLOUD_PROJECT

  # Install kubectl
  #apt-get install kubectl
fi