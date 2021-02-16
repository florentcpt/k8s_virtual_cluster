#!/bin/bash

# Specialized a Kubernetes node as cluster master
#
# Currently designed to be run as a Vagrant provisionner.
# Implementing [K8S documentation](https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
#
# USAGE: k8s_master.sh {k8s_api_ip}
#
# Author: Florent Captier
# Version: 0.1.0

set -e

export DEBIAN_FRONTEND=noninteractive

declare KUBEADM_OPTS="--node-name $HOSTNAME"
declare -r K8S_API_IP="$1"

# Be sure that the following network is in-line with the one declared in k8s_manifests/calico.yml
KUBEADM_OPTS+=" --pod-network-cidr=10.244.0.0/16"  
KUBEADM_OPTS+=" --apiserver-advertise-address=${K8S_API_IP}"

safe_insert_line_in_file() {
	# Safely insert a line in a given file
	# If the line already exists in the file it will be a noop operation (avoiding duplication)
	# USAGE: safe_insert_line_in_file {file} {line}
	
	local FILE="$1"
	shift
	local LINE="$@"
	
	grep -q "^${LINE}$" $FILE || echo "$LINE" >> $FILE
}

install_network_addon() {
	# Install Flannel as network add-on
	# https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tabs-pod-install-4
	sysctl net.bridge.bridge-nf-call-iptables=1
	kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
	kubectl create -f /vagrant/k8s_manifests/calico.yaml
}

initialize_master() {
	# Do not run if kubelet is already active (causing an error otherwise)
	systemctl is-active kubelet && return 0
	kubeadm init $KUBEADM_OPTS
}

create_user_k8s_config() {
	local USER="$1"
	eval local KUBE_CONF=~$USER/.kube/config
	mkdir -p $(dirname $KUBE_CONF)
	cp -if /etc/kubernetes/admin.conf $KUBE_CONF
	chown $(id -u $USER):$(id -g $USER) $KUBE_CONF
}

shell_autocompletion_for_user() {
	local USER="$1"
	eval local SHELL_RC=~$USER/.bashrc
	local SHELL_LINE="source <(kubectl completion bash)"
	
	safe_insert_line_in_file $SHELL_RC $SHELL_LINE
}

shell_aliases_for_user() {
	local USER="$1"
	eval local SHELL_RC=~$USER/.bashrc
	
	safe_insert_line_in_file $SHELL_RC alias k=kubectl
	safe_insert_line_in_file $SHELL_RC complete -F __start_kubectl k
}

initialize_master
create_user_k8s_config root
create_user_k8s_config vagrant
install_network_addon
shell_autocompletion_for_user root
shell_autocompletion_for_user vagrant
shell_aliases_for_user root
shell_aliases_for_user vagrant
