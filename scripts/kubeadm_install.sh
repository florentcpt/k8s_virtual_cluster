#!/bin/bash

# Provision an Ubuntu server with kubeadm, kubelet and kuectl commands to act as a Kubernetes node
#
# Currently designed to be run as a Vagrant provisionner.
# Implementing [K8S documentation](https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
#
# Author: Florent Captier
# Version: 0.1.0

set -e

declare -r DOCKER_USER="vagrant"

disable_swap() {
	swapoff -a
}

set_iptables() {
	modprobe br_netfilter
	# TODO: Make below lines idempotent, currenlty the file content is overrided
	echo "net.bridge.bridge-nf-call-ip6tables = 1" >/etc/sysctl.d/k8s.conf
	echo "net.bridge.bridge-nf-call-iptables = 1" >>/etc/sysctl.d/k8s.conf
	sysctl --system
}

install_docker() {
	apt-get update
	apt-get install -y docker.io
	systemctl enable docker.service
}

grant_docker_to_user() {
	usermod -aG docker $1
}

install_k8s() {
	apt-get update
	apt-get install -y apt-transport-https curl
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	apt-get install -y kubelet kubeadm kubectl
	apt-mark hold kubelet kubeadm kubectl
}

disable_swap
set_iptables
install_docker
grant_docker_to_user $DOCKER_USER
install_k8s
