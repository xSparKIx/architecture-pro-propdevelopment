#!/bin/bash
minikube delete

minikube start

echo "📋 Запуск и проверка задания"

### 1. Создание namespace
echo "🚀 Создаем namespace"
kubectl create namespace audit-zone

kubectl apply -f 01-create-namespace.yaml

### 2. Проверка PodSecurity Admission
echo "📋 Провереям PodSecurity Admission"

bash ./verify/verify-admission.sh

### 3. Установка и проверка Gatekeeper
echo "🚀 Устанавливаем и проверяем Gatekeeper"

bash ./verify/validate-security.sh