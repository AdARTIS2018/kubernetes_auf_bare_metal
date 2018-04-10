#!/bin/sh
## https://kubernetes.io/docs/concepts/cluster-administration/certificates/
## 'kubeadm init' does this 4 u

MASTER_IP=10.0.0.184

mkdir -p /etc/kubernetes/pki
cd /etc/kubernetes/pki 
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${MASTER_IP}" -days 10000 -out ca.crt
openssl genrsa -out server.key 2048
echo "[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = Gy
ST = RLP
L = Huebingen
O = AdARTIS
OU = Cloud
CN = ${MASTER_IP}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
DNS.6 = master01
DNS.7 = master01.fritz.box
IP.1 = ${MASTER_IP}
IP.2 = 10.0.0.187
IP.3 = 10.0.0.188

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
##keyUsage=nonRepudiation,digitalSignature,keyEncipherment
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names" > /etc/kubernetes/pki/csr.conf

openssl req -new -key server.key -out server.csr -config csr.conf

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
-CAcreateserial -out server.crt -days 10000 \
-extensions v3_ext -extfile csr.conf

openssl x509  -noout -text -in ./server.crt

##opensuse tumbleweed - other may be done the same way
##remove older CA
rm /usr/share/pki/trust/anchors/kubernetes.crt
update-ca-certificates

##insert newly created CA
cp ca.crt /usr/share/pki/trust/anchors/kubernetes.crt
update-ca-certificates
