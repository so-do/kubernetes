#!/bin/bash -x

set -euo pipefail

openssl genrsa -out user1.key 2048
openssl req -new -key user1.key -out user1.csr -subj "/CN=user1/O=pod-reader"

openssl genrsa -out user2.key 2048
openssl req -new -key user2.key -out user2.csr -subj "/CN=user2/O=secret-reader"

cat <<EOF > user1.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user1
spec:
  request: $(cat user1.csr | base64 -w0)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 2678400
  usages:
  - client auth
EOF

cat <<EOF > user2.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user2
spec:
  request: $(cat user2.csr | base64 -w0)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 2678400
  usages:
  - client auth
EOF

kubectl apply -f user1.yaml
kubectl apply -f user2.yaml

kubectl certificate approve user1
kubectl certificate approve user2

kubectl get csr user1 -o jsonpath='{.status.certificate}'| base64 -d > user1.crt
kubectl get csr user2 -o jsonpath='{.status.certificate}'| base64 -d > user2.crt

kubectl config set-credentials user1 --client-key=user1.key --client-certificate=user1.crt --embed-certs=true
kubectl config set-credentials user2 --client-key=user2.key --client-certificate=user2.crt --embed-certs=true

kubectl config set-context user1 --cluster=kind-kind --user=user1
kubectl config set-context user2 --cluster=kind-kind --user=user2

kubectl config get-contexts