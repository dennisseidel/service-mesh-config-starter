# Service Mesh Config Starter -> "Your Plattform GitOps Repostiory" - Template

This repository includes the script to setup a plattform currently based on Istio 1.0. In the future further more components will be added e.g. optinally using Apigee for API Management. 

Use the repository to apply [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request):

* Fork it
* Change it & Automate the setup 
  * of your production runtime in the cloud
  * the local developer environment 


## Repository Structure

The devops plattform repo includes a sample for the configuration to setup and maintain the plattform for the remote instances & the local development instances. This includes: 

`config/` : folder including the configurations of all deployed artefacts - each artefact type is in it's own folder, including the template, the config files for the different stages and a README.md file describing it.
- `gke/`: includes the terraform template to setup and config kubernetes on GKE
- `.../`: other config/template files e.g. load balancer/ingress proxy in `network-d10l.yaml`. Add the other templates to this folder and extend the related tasks.
`tasks/`
- `machine-setup.sh`: the script to setup the plattform used by the `Makefile` to setup the plattform.
`Makefile`: This includes different tasks like `setup-plattform-osx` / `setup-plattform-gcp`, `configure-plattform`, `get-plattform-config`


! add some description on how to work / code seperation & repositories: 
- plattform: based on this repo (including all infrastructure & automation pipelines), responsiblilty is: Ops & Security Roles
- micro-service/api-repo: one repo including all the code & pipeline & application specific configs, responsibility service team & security/governance(mostly automated checks)
- service-devops-repo: includes the pipeline to delopy a complete application does not include the code but only the pipleine to deploy ... responsibility: team, sec, ops 

## Getting Started / Tasks

The teams can create pull request on this repo if they need a change - the change must be reviewed by the Ops & Security Role. Use Zalando Zappr to enforce Ops and  Security to review a pull request before a merge. Further automatic checks like consistancy validations can also be implemented as an automatically running pipeline.

In general the automation tasks are defined in the `Makefile`. If it is simply running some commands they are directly add to the make file, if a more complex logic is required, the logic is extracted into a script (either bash or python) in the `tasks` folder. 

The tasks are run using `make {taskname}` (e.g. `make setup-plattform-osx`).

Currently the following tasks are available: 

**Setup Tasks:** This is the location where you would extend the basic plattform. 
* `setup-plattform-osx`: Creates the plattform for local development on OSX based on minikube. 
* `setup-plattform-gcp`: Creates the plattform for "production" (currently the setup is NOT production ready) on GCP Cloud
* `destroy-plattform-osx`: Destroys the plattform locally
* `destroy-plattform-gcp`: Destroys the plattform on the cloud
**Configuration Tasks:** This is the location where you would add the deployment of your configuration like load balancer 
* `configure-plattform`: Configure the plattform (currently the configuration is the same on all clouds, in the future this might take different locations into account)
* `get-plattform-config`: Get the configuration (currently only then ingress ip)

### Clustermanagement 
#### Local (Dev Environment)

To setup a local version of the plattform based on your `config/` and what you define in the `Makefile` do: 

`make setup-plattform-osx` 

The complete command that is run you can finde in the make file.

**Domainsetup:** If you want to use a domain name locally change your `sudo vi /etc/hosts` file and add an entry that maps the ip from `minikube ip` to your subdmain (every subdomain needs a seperate entry!). 


**Features:** Minikube, Helm, Hyberkit, Kubernetes v1.10, /etc/hosts, Istio 1.0, (optional) Local Domain Setup


#### GCP

Before you can setup a cloud version (Google) of the plattform based on your `config/` and what you define in the `Makefile` you need to do some addtional steps: 

1. Create a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) for your project using either the `console/ui` or `gcloud cli`
2. Create a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) and download it as `credentials.json`.
3. Export the service account into the `GOOGLE_CLOUD_KEYFILE_JSON` environment variable (e.g. ``export GOOGLE_CREDENTIALS=`cat credentials.json` ``) **in the terminal window you will run the make command**. 
4. (Customize the terraform configuration under `config/templates/gke` according to the [gcp provider (more info)](https://www.terraform.io/docs/providers/google/index.html) and for the route53 domain the [aws provider](https://www.terraform.io/docs/providers/aws/r/route53_record.html) or set the configuration through env variables: 
  * $GCP_PROJECT: Name of your GCP project *mandatory*
  * $GCP_REGION: The region of your GCP deployment *default: us-central1*
  * $CLUSTER_PW: PW of the kubernetes cluster to be configured *mandatory*
  * $CLUSTER_USER: User of the kubernetes cluster to be configured *mandatory*
  * $CLUSTER_NAME: Name of the cluster to be used.
  * $MACHINE_TYPE: the type of machines the cluster should use (link to google config)
  * $NODE_COUNT: the amount of nodes defined for the clsuter
  * $DOMAIN: the domain where the cluster should be available (requires currently an AWS route53 domain)
Futher configurations should be done in the template itself. 
5. Run `make setup-plattform-gcp`

**Domainsetup:** see above

**Features:** Minikube, Helm, Hyberkit, Kubernetes v1.10, /etc/hosts, Istio 1.0, (optional) Local Domain Setup




updater teraform config and document

* **Features:** GKE, Helm, Kubernetes v1.10, Istio 1.0

### Customize install local & cluster

### Add Load Balancer Config

### Destroy local & cluster

### Update local & cluster