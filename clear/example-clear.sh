#!/bin/bash
read -p "Enter the starting number: " start
read -p "Enter the starting number: " end

if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

for((i=start; i<=end; i++))
do
  kubectl delete po test-pod-$i -n student-$i
  kubectl delete pvc test-pvc-$i -n student-$i
  kubectl delete pv test-pv-vol-$i
  kubectl delete job pi-$i -n student-$i
  kubectl delete -f $HOME/Kubernetes-Multi-Tenant-Practice/WoogiBoogi1129-IT-Convergence-Applications-2nd-Semester-2024 -n student-$i
done