##curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl
##chmod +x kubectl
##mv kubectl /usr/local/bin/

##curl -L  https://github.com/dhiltgen/docker-machine-kvm/ -o /usr/local/bin/docker-machine-driver-kvm
##chmod +x /usr/local/bin/docker-machine-driver-kvm

curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.26.0/minikube-linux-amd64
chmod +x minikube 
mv minikube /usr/local/bin/
rm -Rf ~/.minikube

zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Tumbleweed/Virtualization:containers.repo
zypper refresh
zypper install docker-machine docker-machine-kvm  libvirt kubernetes helm
systemctl enable libvirtd.service;systemctl start libvirtd.service
virsh net-start default
minikube start --vm-driver=kvm --cpus 2 --memory 14000 --disk-size 70g
eval $(minikube docker-env)
minikube update-check

wget https://github.com/fabric8io/gofabric8/releases/download/v0.4.176/gofabric8-linux-amd64
chmod a+x gofabric8-linux-amd64
export GITHUB_OAUTH_CLIENT_ID=6fbfee4e07e179c5eb66
export GITHUB_OAUTH_CLIENT_SECRET=3a40585e0e50c26737e35abe5a22af5862b6bfe7
./gofabric8-linux-amd64 deploy -y
./gofabric8-linux-amd64 validate

##helm init
