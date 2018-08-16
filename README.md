# Service Mesh Config Starter

This repository includes the script to setup a service mesh based on Istio 1.0 locally as well as in the cloud so that you can work with both of them without making changes.

## Getting started

1. The script is included in `/devops` so move to the folder with `cd ./devops`. 
2. Set the environment variable where you want to run it either `export KUBE_ENV=osx` to for a local setup on Mac or `export KUBE_ENV=gcp` to do a setup on the Google Cloud. Other System are currently not supported. 
3. Run the script with `./machine-setup.sh` and follow the terminal outpout. The script will install all prerequisits and after some minuites it should have finished. 

If you want to use a domain name locally change your `sudo vi /etc/hosts` file and add an entry that maps the ip from `minikube ip` to your subdmain (every subdomain needs a seperate entry!). 

### GCP

The script uses terraform to setup your cluster with the [gcp provider (more info)](https://www.terraform.io/docs/providers/google/index.html). Before running it you need to:

* Create a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) for your project using either the `console/ui` or `gcloud cli`
* Create a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) and download it
* Export it into the `GOOGLE_CREDENTIALS` environment variable (e.g. `export GOOGLE_CLOUD_KEYFILE_JSON=$(lpass show gcp-pipeline --attach att-4256166984432642173-1) `)

## Features

### osx 

* Minikube, Helm, Hyberkit, Kubernetes v1.10, /etc/hosts, Istio 1.0 

### gcp 

* GKE, Helm, Kubernetes v1.10, Istio 1.0