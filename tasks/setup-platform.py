#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
import shutil
import os
import subprocess
import shlex
import re
import argparse
from sys import platform
from pathlib import Path


def check_platform(os_platform):
    if os_platform == 'darwin':
        return 'osx'
    else:
        logger.warning(
            "You are using %s. Only OSX currently supported.", os_platform)
        exit("Unsupported OS.")

def go_to_script_location():
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)

def program_exists(command):
    return shutil.which(command) is not None


def run_cmd(cmd_string, capture_output=False, shell=False):
    args = shlex.split(cmd_string)
    return subprocess.run(args, capture_output=capture_output, shell=shell, )


def install_dependencies(os_platform):
    logger.info("Check prerequesits for %s", platform)
    if platform == 'osx':
        if not program_exists("brew"):
            logger.info('Did not find Homebrew. Installing Hombrew.')
            run_cmd(
                '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')
        if not program_exists("docker"):
            logger.info('Did not find Docker. Installing Docker.')
            run_cmd('brew cask install docker')
        if not program_exists("helm"):
            logger.info('Did not find Helm. Installing Helm.')
            run_cmd('brew install kubernetes-helm')


def create_cluster(os_platform, target, stage):
    logger.info("Setup the cluster for %s from %s.", target, os_platform)
    response = run_cmd('kubectl --request-timeout=5s get services', True)
    if response.returncode == 0:
        logger.info("Cluster allready exists.")
    else:
        if target == "local":
            if os_platform == 'osx':
                if not program_exists("minikube"):
                    run_cmd('brew cask install minikube')
                hyperkit_file = Path(
                    "/usr/local/bin/docker-machine-driver-hyperkit")
                if not hyperkit_file.is_file():
                    run_cmd('curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit \
                            && chmod +x docker-machine-driver-hyperkit \
                            && sudo mv docker-machine-driver-hyperkit /usr/local/bin/ \
                            && sudo chown root:wheel /usr/local/bin/docker-machine-driver-hyperkit \
                            && sudo chmod u+s /usr/local/bin/docker-machine-driver-hyperkit')
                run_cmd('minikube start --memory=8192 --cpus=4 --vm-driver=hyperkit -b=localkube \
                        --extra-config=apiserver.Authorization.Mode=RBAC \
                        --extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
                        --extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
                        --kubernetes-version=v1.10.0 \
                        --extra-config=apiserver.ServiceNodePortRange=79-36000')
                os.system('kubectl apply -f ../config/rbac/default-sa-cluster-admin.yaml')
        elif target == "gcp":
            if os_platform == 'osx':
                if not program_exists('terraform'):
                    run_cmd('brew install terraform')
                CLUSTER_USER = os.environ["CLUSTER_USER"]
                CLUSTER_PW = os.environ["CLUSTER_PW"]
                os.system(f"""
                pwd &&
                cd ../config/gke && pwd && terraform init && \ 
                terraform apply -var 'username={CLUSTER_USER}' -var 'password={CLUSTER_PW}' -var-file='{stage}.tfvars' && \
                gcloud container clusters get-credentials d10l-plattform-cluster  --zone us-central1-a --project trusty-acre-156607 && \
                kubectl cluster-info && \
                kubectl create clusterrolebinding cluster-admin-binding \
                             --clusterrole=cluster-admin \
                             --user=$(gcloud config get-value core/account)
                """)
                

def install_istio(target):
    os.system("kubectl label namespace default istio-injection=enabled")
    os.system("kubectl get namespace -L istio-injection")
    args = ['curl', '-L', 'https://git.io/getLatestIstio']
    args2 = ['sh', '-']
    process_curl = subprocess.Popen(args, stdout=subprocess.PIPE,
                                    shell=False)
    process_sh = subprocess.Popen(args2, stdin=process_curl.stdout,
                                  stdout=subprocess.PIPE, shell=False)
    # Allow process_curl to receive a SIGPIPE if process_wc exits.
    process_curl.stdout.close()
    result = process_sh.communicate()[0]
    str_result = result.decode("utf-8")
    try:
        ISTIO_FOLDER = re.search('istio-\d*.\d*.\d*', str_result).group(0)
    except AttributeError:
        logger.error("Download failed. Istio folder does not exist.")
        exit("Istio folder does not exist.")
    run_cmd(f'kubectl apply -f {ISTIO_FOLDER}/install/kubernetes/helm/istio/templates/crds.yaml')
    run_cmd(f'kubectl create -f {ISTIO_FOLDER}/install/kubernetes/helm/helm-service-account.yaml')
    run_cmd("helm init --wait --service-account tiller")
    if target == 'local':
        run_cmd(f'helm install {ISTIO_FOLDER}/install/kubernetes/helm/istio --name istio --namespace istio-system \
                    --set global.proxy.includeIPRanges="" \
                    --set global.crds=false \
                    --set tracing.enabled=true \
                    --set gateways.istio-ingressgateway.type=NodePort \
                    --set gateways.istio-ingressgateway.ports[0].port=80,gateways.istio-ingressgateway.ports[0].name=http2,gateways.istio-ingressgateway.ports[0].nodePort=80 \
                    --set gateways.istio-ingressgateway.ports[1].port=443,gateways.istio-ingressgateway.ports[1].name=https,gateways.istio-ingressgateway.ports[1].nodePort=443 \
                    --set gateways.istio-ingressgateway.ports[2].port=31400,gateways.istio-ingressgateway.ports[2].name=tcp,gateways.istio-ingressgateway.ports[2].nodePort=31400')
        INGRESS_HOST=run_cmd("minikube ip", True, False)
    elif target == 'gcp':
        run_cmd(f'''
            helm install {ISTIO_FOLDER}/install/kubernetes/helm/istio --name istio --namespace istio-system \
                --set global.proxy.includeIPRanges="" \
                --set global.crds=false \
                --set tracing.enabled=true''')
        INGRESS_HOST=run_cmd("kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'", True, False)
    run_cmd("kubectl get svc -n istio-system")
    run_cmd("kubectl get pods -n istio-system")
    INGRESS_PORT = run_cmd(
        'kubectl -n istio-system get service istio-ingressgateway -o jsonpath=\'{.spec.ports[?(@.name=="http2")].nodePort}\'', True, False)
    INGRESS_PORT = INGRESS_PORT.stdout
    logger.info("Ingres Port: " + INGRESS_PORT.decode("utf-8"))
    SECURE_INGRESS_PORT=run_cmd('kubectl -n istio-system get service istio-ingressgateway -o jsonpath=\'{.spec.ports[?(@.name=="https")].nodePort}\'', True, False)
    SECURE_INGRESS_PORT=SECURE_INGRESS_PORT.stdout
    logger.info("Secure Ingress Port: " + SECURE_INGRESS_PORT.decode("utf-8"))
    
    INGRESS_HOST=INGRESS_HOST.stdout
    logger.info('Ingress Host: ' + INGRESS_HOST.decode("utf-8"))

def setup_apigee(stage):
    logger.info('Setup Apigee:')
    os.system(f"""
                cd ../config/apigee &&
                kubectl apply -f {stage}-definitions.yaml &&
                kubectl apply -f {stage}-rule.yaml &&
                kubectl -n istio-system set image deployment/istio-telemetry mixer=gcr.io/apigee-api-management-istio/istio-mixer:1.0.0 &&
                kubectl -n istio-system set image deployment/istio-policy mixer=gcr.io/apigee-api-management-istio/istio-mixer:1.0.0
                """)
    logger.info("IMPORTANT: create a handler.yaml file with the apigee-istio-cli and deploy it by hand.")

def local_setup():
    my_platform = check_platform(platform)
    install_dependencies(my_platform)
    create_cluster(my_platform, "local", 'not_used')
    install_istio('local')

def gcp_setup(stage):
    my_platform = check_platform(platform)
    install_dependencies(my_platform)
    create_cluster(my_platform, "gcp", stage)
    install_istio('gcp')

if __name__ == '__main__':
    logger = logging.getLogger()
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    parser = argparse.ArgumentParser()
    parser.add_argument("type", help="specifies the the deployment e.g. local or gcp, apigee")
    parser.add_argument("--stage", help="stage to deloy to")
    parser.add_argument("--apigee", help="install apigee into the mesh")
    args = parser.parse_args()
    go_to_script_location()
    if args.type == 'local':
        local_setup()
        if args.apigee == 'true':
            setup_apigee(args.stage)
    elif args.type == 'gcp':
        gcp_setup(args.stage)
        if args.apigee == 'true':
            setup_apigee(args.stage)
    elif args.type == 'apigee':
        setup_apigee(args.stage)
    else:
        logger.error("Unkown deployment type. Either use 'local or 'gcp'")
        exit("Unkown deployment type. Either use 'local or 'gcp'")