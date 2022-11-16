#!/bin/bash
# Add User default
export ARN=$(aws iam list-users | jq -r '.Users[]|.Arn')
export USER_ADMIN=$(aws iam list-users | jq -r '.Users[]|.Arn' | awk -F'/' '{print $2}')
export GROUP=system:masters
#GROUP=$(kubectl get configmap -n kube-system aws-auth -o json | jq -r '.data[]' | grep "rolearn" | awk -F':' '{print $7}' | awk -F'/' '{print $2}')

eksctl create cluster --name eks-mundos-e --region us-east-2 --node-type t2.micro --with-oidc --ssh-access --ssh-public-key jenkins --managed --full-ecr-access --zones us-east-2a

eksctl create iamidentitymapping --cluster eks-mundos-e --region=us-east-2 --arn $ARN --username $USER_ADMIN --group $GROUP --no-duplicate-arns
##ejecutar terraform
#cd /home/ubuntu/pin2021/eks_setup_terraform
#sudo terraform init
#sudo terraform apply -auto-approve
#conectarse
#aws eks update-kubeconfig --region region-code --name my-cluster

#create ado serviceacount
kubectl apply -f /home/ubuntu/pin2021/azdo/ado-admin-service-account.yaml
#key adodes
#ADOKEY=$(kubectl get serviceaccounts ado -n kube-system -o jsonpath {.secrets[*].name})

kubectl get serviceaccounts ado -n kube-system -o json | jq -r '.secrets[] | .name' | xargs kubectl get secret  -n kube-system -o json > secret.json

#API Url
kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'


#azure devops

#az extension add --name azure-devops