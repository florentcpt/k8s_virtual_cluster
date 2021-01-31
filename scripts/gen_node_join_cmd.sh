#!/bin/bash

# Generate a command line to be run on a K8S node to join a cluster
#
# This script has to be run on a cluster's master.
# Implementing [K8S documentation](https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes)
#
# Author: Florent Captier
# Version: 0.1.0

set -e

declare MOUNT_POINT="$1"
declare OUTPUT_FILE="${MOUNT_POINT}/$2"

mkdir -p $(dirname $OUTPUT_FILE)

cat >$OUTPUT_FILE <<EOF
#!/bin/bash

# K8S cluster join scipt
# DYNAMICALLY GENERATED

set -e

# Exit if the node is already in the cluster
[ -f /etc/kubernetes/kubelet.conf ] && exit 0

$(kubeadm token create --print-join-command --description "Generated by Vagrant to initialize the cluster")
EOF