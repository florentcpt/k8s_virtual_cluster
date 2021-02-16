#!/bin/bash

# Provision an Ubuntu server with kubeadm, kubelet and kuectl commands to act as a Kubernetes node
#
# Currently designed to be run as a Vagrant provisionner.
# Implementing [K8S documentation](https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
#
# Author: Florent Captier
# Version: 0.1.0

set -e

export DEBIAN_FRONTEND=noninteractive

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

install_container_runtime() {
	# Install containerd as container runtime
	# See [doc](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd)
	
	# Pre-requisites
	echo "overlay" > /etc/modules-load.d/containerd.conf
	echo "br_netfilter" >> /etc/modules-load.d/containerd.conf

	modprobe overlay
	modprobe br_netfilter

	# Setup required sysctl params, these persist across reboots.
	echo "net.bridge.bridge-nf-call-iptables = 1" > /etc/sysctl.d/99-kubernetes-cri.conf
	echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
	echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf

	# Apply sysctl params without reboot
	sysctl --system
	
	# Install containerd
	apt-get update && apt-get install -y containerd
	
	# Apply a default config if not existing
	if [ ! -d /etc/containerd ]; then
		mkdir -p /etc/containerd
		containerd config default > /etc/containerd/config.toml
	fi
	
	# Restart containerd
	systemctl restart containerd
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
install_container_runtime
install_k8s
