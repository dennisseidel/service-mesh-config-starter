# Service Mesh Config Starter

This repository includes the script to setup a service mesh based on Istio 1.0 locally as well as in the cloud so that you can work with both of them without making changes.

## Getting started

1. The script is included in `/devops` so move to the folder with `cd ./devops`. 
2. Set the environment variable where you want to run it either `export KUBE_ENV=osx` to for a local setup on Mac or `export KUBE_ENV=gcp` to do a setup on the Google Cloud. Other System are currently not supported. 
3. Run the script with `./machine-setup.sh` and follow the terminal outpout. The script will install all prerequisits and after some minuites it should have finished. 

If you want to use a domain name locally change your `sudo vi /etc/hosts` file and add an entry that maps the ip from `minikube ip` to your subdmain (every subdomain needs a seperate entry!). 

## Features

### osx 

* Minikube, Helm, Hyberkit, Kubernetes v1.10, /etc/hosts, Istio 1.0 

### gcp 

* GKE, Helm, Kubernetes v1.10, Istio 1.0