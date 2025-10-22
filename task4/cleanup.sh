#!/bin/bash

echo "🧹 Cleaning up RBAC setup..."

kubectl delete -f rolebindings.yaml --ignore-not-found=true
kubectl delete -f roles.yaml --ignore-not-found=true

kubectl delete csr ivan-petrov anna-sidorova jenkins-bot --ignore-not-found=true

# Удаляем контексты пользователей
kubectl config delete-context ivan.petrov-context --ignore-not-found=true
kubectl config delete-context anna.sidorova-context --ignore-not-found=true
kubectl config delete-context jenkins-bot-context --ignore-not-found=true

# Удаляем credentials
kubectl config unset users.ivan.petrov
kubectl config unset users.anna.sidorova  
kubectl config unset users.jenkins-bot

# Удаляем директорию с сертификатами
rm -rf ~/.kube/users

echo "✅ Cleanup completed"