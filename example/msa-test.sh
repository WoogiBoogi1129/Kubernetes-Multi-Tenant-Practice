#!/bin/bash
read -p "Enter the starting number: " start
read -p "Enter the starting number: " end

if ! [[ "$start" =~ ^[0-9]+$ ]] || ! [[ "$end" =~ ^[0-9]+$ ]] || [ "$start" -gt "$end" ]; then
  echo "Please enter valid numbers. The starting number must be less than the ending number."
  exit 1
fi

git clone https://github.com/WoogiBoogi1129/WoogiBoogi1129-IT-Convergence-Applications-2nd-Semester-2024.git

for((i=start; i<=end; i++))
do
  kubectl config use-context student-$i
  kubectl apply -f /WoogiBoogi1129-IT-Convergence-Applications-2nd-Semester-2024
done

kubectl config use-context kubernetes-admin@kubernetes
