# Kubernetes virtual cluster

Used to test Kubernetes locally, this repository build a virtual K8S cluster using [Vagrant](https://vagrant.io) and [Virtualbox](https://www.virtualbox.org).

Most of it was inspired by [Xavki Kerbenetes courses](https://xavki.blog/kubernetes-tutoriaux-francais/).

It will create 2 VMs (Ubuntu-based), one acting as K8S cluster master, the other one as a classic K8S cluster node.

## Pre-requisites

- Vagrant 2.2.14
- Virtualbox 6.1

## Usage

- Clone this repository
- Run `vagrant up`

At this stage you should have a working cluster.

You can now connect to the master : `vagrant ssh master`
And use `kubectl`, `kubeadm` commands.

ENJOY :smile:

### Set the cluster size

You can specify the size of the cluster (minimum 2) by setting the `K8S_CLUSTER_SIZE` variable.

## Tips

### Get the K8S cluster state

```shell
$ vagrant ssh master
# [...]
vagrant@kubemaster:~$ sudo kubectl get nodes -o wide
```

## Known issues

If you created a cluster specifying a custom size, do not forget to set the environment variable to see other commands (`status`, `ssh`, `destroy`, ...) working.
Otherwise vagrant will try to deal with the default cluster size.
