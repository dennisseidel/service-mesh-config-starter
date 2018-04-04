#!/bin/bash

set -ex

# Donwload latest version and set path variable to istio for istioctl e.g. "$PATH:/Users/den/repo/test/istio-0.6.0/bin"
curl -L https://git.io/getLatestIstio | sh -
export ISTIO_DIR="$(find . -type d -name istio-*.*  -exec basename {} \;)"

# install configure ingress rules
kubectl apply -f <($PWD/$ISTIO_DIR/bin/istioctl kube-inject -f devops/config/ingress.yaml)

clustercheck=$(gcloud compute firewall-rules describe "allow-book" --verbosity=none)
if [[ $clustercheck != *"allow-book"* ]]; then
  gcloud compute firewall-rules create allow-book --allow tcp:$(kubectl get svc istio-ingress -n istio-system -o jsonpath='{.spec.ports[0].nodePort}')
fi