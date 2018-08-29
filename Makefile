
setup-platform-local:
	tasks/setup-platform.py local

delete-platform-local:
	minikube delete

setup-platform-gcp-dev:
	tasks/setup-platform.py gcp --stage=dev
# add more tasks for different stages you require

delete-platform-gcp-dev:
	cd config/gke && terraform destroy -var username=${CLUSTER_PW} -var password=${CLUSTER_PW} -var-file=dev.tfvars
	
configure-platform:
	kubectl apply -f config/templates/network-d10l.yaml
	# add more plattform configuration - if it gets to complex outsource it into its own tasks scrip

get-platform-config:
	kubectl -n istio-system get service istio-ingressgateway -o 'jsonpath={.status.loadBalancer.ingress[0].ip}'
	# add more plattform configuration - if it gets to complex outsource it into its own tasks script