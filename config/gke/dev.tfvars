region = "us-central1" # The region of your GCP deployment
gcp_project = "trusty-acre-156607"   # Name of your GCP project
clustername = "d10l-plattform-cluster" #  Name of the cluster to be used.
kubernetes_version = "1.10.5-gke.4" # optional / default: 1.10.5-gke.4 / the kubernetes version of the cluster
node_count = "3" # optional / default: 3 / the amount of nodes defined for the clsuter
machine_type = "n1-standard-1" # optional / default: n1-standard-1 / the type of machines the cluster should use (types: https://cloud.google.com/compute/docs/machine-types)
preemptible = "true" # optional / default: false / should preemtible instances be use - can be killed at any time by google but are cheaper