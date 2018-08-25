
setup-plattform-local:
	export KUBE_ENV=osx && \
	../tasks/machine-setup.sh

setup-plattform-gcp:
	export KUBE_ENV=gcp && \
	../tasks/machine-setup.sh && \
	echo "create secrets && other prerequesits"
	
configure-plattform:
	kubectl apply -f config/templates/network-d10l.yaml

get-plattform-config:
	kubectl -n istio-system get service istio-ingressgateway -o 'jsonpath={.status.loadBalancer.ingress[0].ip}'
	
