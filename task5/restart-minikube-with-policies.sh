#!/bin/bash

echo "🚀 Restarting Minikube with Network Policy support..."

# 1. Останавливаем текущий Minikube
minikube stop

# 2. Удаляем текущий кластер
minikube delete

# 3. Запускаем Minikube с Calico CNI (поддерживает Network Policies)
echo "Starting Minikube with Calico CNI..."
minikube start \
  --network-plugin=cni \
  --cni=calico \
  --kubernetes-version=v1.28.0 \
  --driver=docker \
  --cpus=2 \
  --memory=4096

# 4. Ждем пока Calico запустится
echo "⏳ Waiting for Calico to be ready..."
kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=180s
kubectl wait --for=condition=ready pod -l k8s-app=calico-kube-controllers -n kube-system --timeout=180s

echo "✅ Minikube with Network Policy support is ready!"

# 5. Проверяем что Network Policies поддерживаются
echo "📋 Checking CNI plugin..."
kubectl get pods -n kube-system | grep calico

echo "🎯 Now Network Policies should work correctly!"