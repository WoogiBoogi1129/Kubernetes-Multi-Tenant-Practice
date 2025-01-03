#!/bin/bash
read -p "Enter the starting number: " start
read -p "Enter the starting number: " end

if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

mkdir $HOME/Kubernetes-Multi-Tenant-Practice/kubeconfig-file

for((i=start; i<=end; i++))
do
  sudo mkdir -p /home/student-$i/.kube
  kubectl config use-context student-$i
  kubectl config view --minify --flatten > $HOME/Kubernetes-Multi-Tenant-Practice/kubeconfig-file/student-$i.yaml
done

kubectl config use-context kubernetes-admin@kubernetes

for((i=start; i<=end; i++))
do
  cd
  sudo cp $HOME/Kubernetes-Multi-Tenant-Practice/kubeconfig-file/student-$i.yaml /home/student-$i/.kube/config
  sudo chown student-$i:student-$i /home/student-$i/.kube/config
done