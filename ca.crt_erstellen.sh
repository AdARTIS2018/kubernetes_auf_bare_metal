#/bin/sh
MASTER_IP=10.1.0.203
mkdir -p /etc/kubernetes/pki
cd /etc/kubernetes/pki 
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${MASTER_IP}" -days 10000 -out ca.crt
openssl genrsa -out server.key 2048
