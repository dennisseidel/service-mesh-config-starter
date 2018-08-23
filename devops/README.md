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

### Customize install local & cluster

### Add Load Balancer Config

### Destroy local & cluster

### Update local & cluster