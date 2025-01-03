#!/bin/bash
read -p "Enter the starting number: " start
read -p "Enter the starting number: " end

if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

for((i=start; i<=end; i++))
do
  kubectl config use-context student-$i
  cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-$i
spec:
  completions: 12
  parallelism: 6
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34.0
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
EOF
done

kubectl config use-context kubernetes-admin@kubernetes
watch kubectl get job -A -o wide
