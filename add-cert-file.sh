#!/bin/bash
read -p "Enter the starting number: " start
read -p "Enter the starting number: " end

if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

sudo mkdir $HOME/Kubernetes-Multi-Tenant-Practice/csr
cd $HOME/Kubernetes-Multi-Tenant-Practice/csr/

for ((i=start; i<=end; i++))
do
  mkdir student-$i
done

for ((i=start; i<=end; i++))
do
  cd $HOME/Kubernetes-Multi-Tenant-Practice/csr/student-$i
  openssl genrsa -out student-$i.key 2048
  openssl req -new -key student-$i.key -subj "/CN=student-$i" -out student-$i.csr
done

cd $HOME/Kubernetes-Multi-Tenant-Practice/csr/

for ((i=start; i<=end; i++))
do
  cp $HOME/Kubernetes-Multi-Tenant-Practice/example-csr.yaml $HOME/Kubernetes-Multi-Tenant-Practice/csr/student-$i/student-$i-csr.yaml
  sed -i "/^  name/c\  name: student-$i" student-$i/student-$i-csr.yaml
  sed -i "/^  request/c\  request: `cat student-$i/student-$i.csr | base64 | tr -d "\n"`" student-$i/student-$i-csr.yaml
done

for ((i=start; i<=end; i++))
do
  kubectl apply -f student-$i/student-$i-csr.yaml
  kubectl certificate approve student-$i
done

for ((i=start; i<=end; i++))
do
  cd $HOME/Kubernetes-Multi-Tenant-Practice/csr/student-$i/
  kubectl get csr student-$i -o jsonpath='{.status.certificate}' | base64 -d > student-$i.crt
  kubectl config set-credentials student-$i --client-key=student-$i.key --client-certificate=student-$i.crt --embed-certs=true
  kubectl config set-context student-$i --cluster=kubernetes --user=student-$i --namespace=student-$i
  cd ..
done
