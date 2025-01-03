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
apiVersion: v1
kind: PersistentVolume
metadata: 
  name: test-pv-vol-$i
  labels: 
    type: local
spec: 
  capacity: 
    storage: 10Gi
  accessModes: 
    - ReadWriteOnce
  hostPath: 
    path: "/mnt/data-$i"
EOF

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc-$i
  labels:
    type: local
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  volumeName: test-pv-vol-$i  # 연결할 PV 이름
EOF

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod-$i
spec:
  containers:
  - name: test-container-$i
    image: busybox  # 사용할 이미지 (예: busybox)
    command: ['sh', '-c', 'echo Hello from test-pod-$i; sleep 3600']
    volumeMounts:
    - mountPath: /mnt/data
      name: test-volume
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: test-pvc-$i  # 연결할 PVC 이름
EOF
done

kubectl config use-context kubernetes-admin@kubernetes