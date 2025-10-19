#!/bin/bash

echo "⚙️ Setting up user kubeconfig files with absolute paths..."

HOME_DIR="$HOME"
KUBE_USER_DIR="$HOME_DIR/.kube/users"

# Переходим в директорию с сертификатами
cd "$KUBE_USER_DIR"

CLUSTER_NAME="minikube"
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

echo "🔧 Configuring cluster: $CLUSTER_NAME"
echo "🔧 API Server: $APISERVER"

# Для developer - Иван Петров
kubectl config set-credentials ivan.petrov \
  --client-certificate="$KUBE_USER_DIR/ivan.petrov.crt" \
  --client-key="$KUBE_USER_DIR/ivan.petrov.key" \
  --embed-certs=true

kubectl config set-context ivan.petrov-context \
  --cluster=$CLUSTER_NAME \
  --user=ivan.petrov \
  --namespace=default

# Для security-auditor - Анна Сидорова
kubectl config set-credentials anna.sidorova \
  --client-certificate="$KUBE_USER_DIR/anna.sidorova.crt" \
  --client-key="$KUBE_USER_DIR/anna.sidorova.key" \
  --embed-certs=true

kubectl config set-context anna.sidorova-context \
  --cluster=$CLUSTER_NAME \
  --user=anna.sidorova

# Для ci-bot - Jenkins
kubectl config set-credentials jenkins-bot \
  --client-certificate="$KUBE_USER_DIR/jenkins-bot.crt" \
  --client-key="$KUBE_USER_DIR/jenkins-bot.key" \
  --embed-certs=true

kubectl config set-context jenkins-bot-context \
  --cluster=$CLUSTER_NAME \
  --user=jenkins-bot

echo "✅ User kubeconfig files created with absolute paths"