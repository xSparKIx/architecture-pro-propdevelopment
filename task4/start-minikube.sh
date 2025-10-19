#!/bin/bash

echo "🚀 Starting Minikube cluster..."

# Останавливаем и удаляем старый кластер
minikube stop 2>/dev/null || true
minikube delete 2>/dev/null || true

# Запускаем без интерактивных запросов
# Для задания 5 подключаем calico
minikube start \
  --network-plugin=cni \
  --cni=calico \
  --kubernetes-version=v1.28.0 \
  --driver=docker \
  --cpus=2 \
  --memory=4096

# Ждем полного запуска
sleep 30

# Проверяем статус
echo "📊 Cluster status:"
minikube status

echo "✅ Minikube cluster is ready!"