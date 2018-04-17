##curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl
##chmod +x kubectl
##mv kubectl /usr/local/bin/

##curl -L  https://github.com/dhiltgen/docker-machine-kvm/ -o /usr/local/bin/docker-machine-driver-kvm
##chmod +x /usr/local/bin/docker-machine-driver-kvm

MINIKUBE_VERSION=v0.26.0
curl -Lo docker-machine-driver-kvm2 https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/docker-machine-driver-kvm2
chmod +x docker-machine-driver-kvm2
mv docker-machine-driver-kvm2 /usr/local/bin/

curl -Lo minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64
chmod +x minikube 
mv minikube /usr/local/bin/
rm -Rf ~/.minikube

zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Tumbleweed/Virtualization:containers.repo
zypper refresh
zypper install docker-machine docker-machine-kvm  libvirt helm policycoreutils
systemctl enable libvirtd.service;systemctl start libvirtd.service
##latest kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/\
$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

virsh net-start default
minikube delete
rm -rf ~/.minikube
minikube start --vm-driver=kvm --cpus 3 --memory 14000 --disk-size 70g
eval $(minikube docker-env)
minikube addons enable ingress
minikube update-check

##download latest fabric8
rm -rf download.txt
wget https://get.fabric8.io/download.txt --no-check-certificate && mv download.txt download.sh
chmod a+x download.sh
./download.sh
##wget https://github.com/fabric8io/gofabric8/releases/download/v0.4.176/gofabric8-linux-amd64
##chmod a+x gofabric8-linux-amd64
echo "
export GITHUB_OAUTH_CLIENT_ID=6fbfee4e07e179c5eb66
export GITHUB_OAUTH_CLIENT_SECRET=3a40585e0e50c26737e35abe5a22af5862b6bfe7
export PATH=$PATH:~/.fabric8/bin" > ~/.bashrc
source ~/.bashrc
echo "OAUTH Settings to
>>http://keycloak-fabric8.$(minikube ip).nip.io/auth/realms/fabric8/broker/github/endpoint<<
^^^^^^^^^^^^^^^^^^^^
===================="
read -p "Press RETURN"
gofabric8 deploy --package system -n fabric8
gofabric8 validate
##helm init
