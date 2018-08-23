# Service Mesh Config Starter

This repository includes the script to setup a service mesh based on Istio 1.0 locally as well as in the cloud so that you can work with both of them without making changes.

## Getting started

1. The script is included in `/devops` so move to the folder with `cd ./devops`. 
2. Set the environment variable where you want to run it either `export KUBE_ENV=osx` to for a local setup on Mac or `export KUBE_ENV=gcp` to do a setup on the Google Cloud. Other System are currently not supported. 
3. Run the script with `./machine-setup.sh` and follow the terminal outpout. The script will install all prerequisits and after some minuites it should have finished. 

If you want to use a domain name locally change your `sudo vi /etc/hosts` file and add an entry that maps the ip from `minikube ip` to your subdmain (every subdomain needs a seperate entry!). 


# Plattform DevOps Repository

The devops plattform repo includes a sample for the configuration to setup and maintain the plattform for the remote instances & the local development instances. This includes: 

* Ops Automation (installation & update scripts) `ops`
  * Infrastructure
  * Plattform
* Plattform Configuration
  * Gateway Config

This repo should be the foundation for [GitOps](tbd) for the Service Mesh.

## Repository Structure

`config/`
- `stages.yaml`: config file used to parameterize the different stages > *what is the format / what is different between stages?*
- `artefacts/`: templates of all deployed artefacts
  - `gke/`: gke setup and config
  - `...`: other config/template files e.g. load balancer ...
`tasks/`
- `machine-setup.sh`: plattform setup

## Tasks

The teams can create pull request on this repo if they need a change - the change must be reviewed by the Ops & Security Role. Use Zalando Zappr to enforce Ops and  Security to review a pull request before a merge. Further automatic checks like consistancy validations can also be implemented as an automatically running pipeline.

### Install local & cluster
#### Local (Dev Environment)

1. ...
2. ...

* **Features:** Minikube, Helm, Hyberkit, Kubernetes v1.10, /etc/hosts, Istio 1.0 


#### GCP

The script uses terraform to setup your cluster with the [gcp provider (more info)](https://www.terraform.io/docs/providers/google/index.html). Before running it you need to:

1. Create a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) for your project using either the `console/ui` or `gcloud cli`
2. Create a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) and download it
3. Export it into the `GOOGLE_CREDENTIALS` environment variable (e.g. `export GOOGLE_CLOUD_KEYFILE_JSON=$(lpass show gcp-pipeline --attach att-4256166984432642173-1) `)
4. Customize the terraform template under `config/gke` with `zone`, `cluster_name`, `machine_type` more config options are documented at the [gcp provider (more info)](https://www.terraform.io/docs/providers/google/index.html).
5. Set the environement variable `export KUBE_ENV=gcp`
6. Run the the `tasks/` `setup-maschine.sh` 

* **Features:** GKE, Helm, Kubernetes v1.10, Istio 1.0

### Customize install local & cluster

### Add Load Balancer Config

### Destroy local & cluster

### Update local & cluster