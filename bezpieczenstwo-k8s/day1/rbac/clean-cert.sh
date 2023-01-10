#!/bin/bash -x

kubectl delete -f user1.yaml
kubectl delete -f user2.yaml

rm user1.crt user1.csr user1.key user1.yaml
rm user2.crt user2.csr user2.key user2.yaml

kubectl config delete-context user1
kubectl config delete-context user2

kubectl config delete-user user1
kubectl config delete-user user2
