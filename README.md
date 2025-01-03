# Kubernetes-Multi-Tenant-Practice
클러스터 하나에서 여러 명의 유저들이 독립적으로 실습할 수 있는 환경 구축 쉘 모음

해당 repository는 하나의 클러스터 환경에서 여러명의 학생들이 독립적인 공간에서 실습을 진행할 수 있도록 제작한 Multi-Tenant 환경 구축을 자동화한 스크립트들의 모음입니다.

Kubernetes 환경 설치가 이루어지지 않았다면 아래 링크를 참고하여 Cluster 구성 후, 환경 구축을 진행하세요.
rink: https://github.com/WoogiBoogi1129/Kubernetes_Installer

### 한번에 설치하기
1. 아래 쉘 스크립트를 실행하여 한번에 환경을 구성하세요.
```sh
sudo chmod +x /Kubernetes-Multi-Tenant-Practice/Multi-Tenant-Installer.sh
./Multi-Tenant-Installer.sh
```

### 단계별로 설치하기
1. user 생성하기
- 클러스터 환경에서 root 권한을 가진 계정에 학생들이 접근하지 않도록 하려면, ubuntu의 user를 분리하여 접근할 수 있도록 해야합니다. 아래 쉘 스크립트를 실행하여 user를 생성합니다.
```sh
sudo chmod +x /Kubernetes-Multi-Tenant-Practice/add-ubuntu-user.sh
./add-ubuntu-user.sh
```
- 주의: 해당 스크립트는 비밀번호와 특정 정보들을 입력하는 입력창이 뜹니다. 해당 부분은 현재 자동화를 하려다가 expect 활용을 잘 못해서 구현하지 못했습니다. (차후 수정 예정) 이 파트에서는 password 설정을 수동으로 해야합니다.

2. namespace 생성하기
- 해당 Multi-Tenant 환경을 구축하는 방식으로 namespace 단위로 분리하는 방법으로 제작했습니다. namespace를 자동으로 생성하기 위해 아래 쉘 스크립트를 실행합니다.
```sh
sudo chmod +x /Kubernetes-Multi-Tenant-Practice/add-namespace.sh
./add-namepsace.sh
```

3. csr 파일 생성하기
- 클러스터에 user 정보들 즉, context를 추가하기 위해서는 자격 인증 파일인 key와 csr, crt 파일을 생성해야합니다. 아래 쉘 스크립트를 실행하여 인증 관련 파일들을 생성합니다.
```sh
sudo chmod +x /Kubernetes-Multi-Tenant-Practice/add-cert-file.sh
./add-cert-file.sh
```

4. role, rolebinding 생성하기
- context가 추가되면, 각 user에게 어떤 권한을 부여할 지 설정하는 role, rolebinding을 생성합니다. 아래 쉘 스크립트를 실행하여 RBAC 관련 리소스들을 생성합니다.
```sh
sudo chmod +x /Kubernetes-Multi-Tenant-Practice/add-role.sh
./add-role.sh
```
5. 각 유저 context 파일 추출하기
- 각 유저들의 context 파일을 추출하여 개인 PC에서 master node에 접근하지 않고, root 권한을 함부로 사용할 수 없도록 하기 위해 kubeconfig 파일과 openVPN 구성 파일만 넘겨줄 수 있도록 세팅하는 과정입니다. 아래 쉘 스크립트를 실행하여 각 context 파일을 추출하세요.
```sh
sudo chmod +x /Kubernetes-Multi-Tenant-Practice/separate-kubeconfig.sh
./separate-kubeconfig.sh
```

6. 이제 모든 준비가 끝났습니다. 임의의 ubuntu-user로 접근하여 명령어들을 입력해보시면 됩니다.
```sh
ssh [user name]@[node ip]

# 아래 명령어 입력 시, student가 할당받은 namespace가 default로 출력되어, 아무것도 없다고 나옴
kubectl get po

# 모든 네임스페이스의 리소스를 보려고 해도 권한이 없어 나오지 않음
kubectl get all -A
```

### Example 실습
- 클러스터가 정상적으로 동작하는지 확인하기 위해 대표적인 실습을 진행해볼 수 있습니다. `/example` 디렉토리에서 여러개의 자동화된 쉘을 통해 클러스터가 정상적으로 동작하는지 확인할 수 있습니다. 설치과정과 같이 `sudo chmod +x [파일이름.sh]`와 `./[파일이름.sh]`를 통해 동작시켜볼 수 있습니다.
1. `example/job-test.sh`: Job 리소스로 Node의 리소스 처리 성능을 확인할 수 있습니다.
2. `exmaple/msa-test.sh`: Voting App을 배포하여 Service 리소스와 Deployment 리소스가 정상적으로 동작하는지 확인할 수 있습니다.
3. `example/pv-pvc-test.sh`: PV, PVC를 활용하여 볼륨이 정상적으로 동작하는지 확인할 수 있습니다.
- 주의: PV-PVC 실습의 경우, PV는 namespace 단위로 관리되는 리소스가 아니기에 다른 학생들이 본인의 PV 외 다른 PV에 접근할 수 있습니다. 실습을 진행할 경우,학생들에게 주의사항을 안내하여 다른 PV를 수정하지 않도록 미리 공지해야합니다.

### 실습 후 정리하기
- 실습 후 깨끗한 환경을 유지하고 싶을 경우, 아래 쉘 스크립트를 통해 초기화할 수 있습니다.
1. `cleanup.sh`: 쿠버네티스 클러스터만 남기고 초기단계로 모든 데이터를 삭제합니다.
2. `example-clear.sh`: 모든 Example 실행 후 생성된 리소스를 삭제합니다.