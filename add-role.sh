#!/bin/bash
read -p "Enter the starting number: " start
read -p "Enter the starting number: " end

if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

kubectl create clusterrole student --verb=get,list,create,update,patch,delete --resource=pv,storageclass
kubectl create clusterrole node-role --verb=get,list --resource=node,namespace

for((i=start; i<=end; i++))
do
        kubectl create role student-$i --namespace=student-$i --verb=get,watch,list,create,update,patch,delete,top --resource=pods,pods/log,pods/exec,deployments,deployments/scale,service,endpoints,daemonset,statefulset,pvc,configmap,secret,role,rolebinding,replicasets,replicasets/scale,replicationcontrollers,horizontalpodautoscalers,cronjobs,jobs
        kubectl create rolebinding student-$i --role=student-$i --user=student-$i --namespace=student-$i

        kubectl create clusterrolebinding student-$i --user=student-$i --clusterrole=student
        kubectl create clusterrolebinding node-rolebinding-$i --user=student-$i --clusterrole=node-role
done
