#!/bin/bash

read -p "Enter the starting number: " start
read -p "Enter the ending number: " end

# Validate the input numbers
if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

sudo rm -rf $HOME/Kubernetes-Multi-Tenant-Practice/csr/
sudo rm -rf $HOME/Kubernetes-Multi-Tenant-Practice/kubeconfig-file/

for ((i=start; i<=end; i++))
do
  kubectl delete rolebinding student-$i --namespace=student-$i
  kubectl delete role student-$i --namespace=student-$i
  kubectl delete clusterrolebinding student-$i
  kubectl delete clusterrolebinding node-rolebinding-$i
done

kubectl delete clusterrole student
kubectl delete clusterrole node-role

for ((i=start; i<=end; i++))
do
  kubectl config delete-context student-$i
  kubectl delete namespace student-$i
  kubectl delete csr student-$i
  #sudo deluser student-$i
  sudo rm -rf /home/student-$i/.kube
done