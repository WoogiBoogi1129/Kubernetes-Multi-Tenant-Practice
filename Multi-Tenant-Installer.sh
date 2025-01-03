#!/bin/bash
read -p "Enter the starting number: " start
read -p "Enter the starting number: " end

if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

for ((i=start; i<=end; i++))
do
  sudo adduser student-$i
done

for ((i=start; i<=end; i++))
do
  kubectl create ns student-$i
done

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

kubectl create clusterrole student --verb=get,list,create,update,patch,delete --resource=pv,storageclass
kubectl create clusterrole node-role --verb=get,list --resource=node,namespace

for((i=start; i<=end; i++))
do
        kubectl create role student-$i --namespace=student-$i --verb=get,watch,list,create,update,patch,delete,top --resource=pods,pods/log,pods/exec,deployments,deployments/scale,service,endpoints,daemonset,statefulset,pvc,configmap,secret,role,rolebinding,replicasets,replicasets/scale,replicationcontrollers,horizontalpodautoscalers,cronjobs,jobs
        kubectl create rolebinding student-$i --role=student-$i --user=student-$i --namespace=student-$i

        kubectl create clusterrolebinding student-$i --user=student-$i --clusterrole=student
        kubectl create clusterrolebinding node-rolebinding-$i --user=student-$i --clusterrole=node-role
done

sudo mkdir $HOME/Kubernetes-Multi-Tenant-Practice/kubeconfig-file

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