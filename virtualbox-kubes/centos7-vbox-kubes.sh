#!/bin/bash
echo make sure swap is off swapoff -a OR don't install a swap partition at all!!!
echo ================================

yum -y --enablerepo=extras install epel-release
yum -y install dkms net-tools mlocate wget docker
yum -y groupinstall "Development Tools"
yum -y install kernel-devel
## vorher das Image auf dem HOST mounten _(VBoxGuestAdditions.iso)_
mount /dev/cdrom /mnt
/mnt/VBoxLinuxAdditions.run
yum -y update
##hostnamectl set-hostname kubemaster 
##hostnamectl set-hostname kubenode1..n
systemctl enable docker && systemctl start docker

##install kubernetes
##==================
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

##centos routing problems
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

##Configure SELINUX=disabled OR permissive in the /etc/selinux/config file
docker info | grep -i cgroup
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf |grep cgroup-driver
echo the above lines must be equal!!!! or kubelet won't start
kubeadm init
