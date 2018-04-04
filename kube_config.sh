#!/bin/sh
swapoff -a
touch /etc/kubernetes/bootstrap-kubelet.conf
kubeadm init
