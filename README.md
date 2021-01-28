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
