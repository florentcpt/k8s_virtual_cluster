#!/bin/bash

set -e

declare -r DOCKER_USER="vagrant"

disable_swap() {
	swapoff -a
}

install_docker() {
	apt-get update
	apt-get install -y docker.io
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
install_docker
grant_docker_to_user $DOCKER_USER
install_k8s
