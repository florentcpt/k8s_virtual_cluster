#!/bin/bash

# Specialized a Kubernetes node as cluster master
#
# Currently designed to be run as a Vagrant provisionner.
# Implementing [K8S documentation](https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
#
# Author: Florent Captier
# Version: 0.1.0

set -e

declare KUBEADM_OPTS="--node-name $HOSTNAME"
# TODO: Retrieve IP from script options
declare K8S_API_IP="192.168.56.101"

# Set pod-network-cidr according to Flannel requisites
KUBEADM_OPTS+=" --pod-network-cidr=10.244.0.0/16"  
KUBEADM_OPTS+=" --apiserver-advertise-address=${K8S_API_IP}"

install_network_addon() {
	# Install Flannel as network add-on
	# https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tabs-pod-install-4
	sysctl net.bridge.bridge-nf-call-iptables=1
	kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

initialize_master() {
	# Do not run if kubelet is already active (causing an error otherwise)
	systemctl is-active kubelet && return 0
	kubeadm init $KUBEADM_OPTS
}

create_user_k8s_config() {
	local KUBE_CONF="$HOME/.kube/config"
	mkdir -p $(dirname $KUBE_CONF)
	cp -if /etc/kubernetes/admin.conf $KUBE_CONF
	chown $(id -u):$(id -g) $KUBE_CONF
}

initialize_master
create_user_k8s_config
install_network_addon