#!/bin/bash
echo make sure swap is off swapoff -a OR don't install a swap partition at all!!!
echo ================================
echo you need 2 network adapter one NAT (bridged NAT does not work !!!)
echo and one host-only adapter (normaly 192.168.99.100 linked)

yum -y --enablerepo=extras install epel-release
yum -y install dkms net-tools mlocate wget docker acpid jq golang
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
yum install -y kubelet kubeadm kubectl golang
systemctl enable kubelet && systemctl start kubelet

mkdir download
cd download
wget https://github.com/kubernetes-incubator/cri-tools/archive/master.zip
unzip master.zip
cd cri-tools-master
make
make install
export PATH=$PATH:/usr/local/bin
echo "export PATH=\$PATH:/usr/local/bin" > /etc/profile.d/myPATH.sh

##centos routing problems
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo Configure SELINUX=disabled OR permissive in the /etc/selinux/config file
echo ========================================================================

mkdir -p /etc/cni/net.d
echo 
kubeadm init --pod-network-cidr=192.168.0.0/16
docker info | grep -i cgroup
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf |grep cgroup-driver
echo
echo "the above lines must be equal!!!! or kubelet won't start"


## search and install networking addons https://kubernetes.io/docs/concepts/cluster-administration/addons/
