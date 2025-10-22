#!/bin/bash

echo "📝 Approving Certificate Signing Requests..."

# Подписываем CSR через Minikube
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ivan-petrov
spec:
  request: $(cat ~/.kube/users/ivan.petrov.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
---
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: anna-sidorova
spec:
  request: $(cat ~/.kube/users/anna.sidorova.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
---
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jenkins-bot
spec:
  request: $(cat ~/.kube/users/jenkins-bot.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Одобряем CSR
kubectl certificate approve ivan-petrov
kubectl certificate approve anna-sidorova
kubectl certificate approve jenkins-bot

# Получаем подписанные сертификаты
kubectl get csr ivan-petrov -o jsonpath='{.status.certificate}' | base64 -d > ~/.kube/users/ivan.petrov.crt
kubectl get csr anna-sidorova -o jsonpath='{.status.certificate}' | base64 -d > ~/.kube/users/anna.sidorova.crt
kubectl get csr jenkins-bot -o jsonpath='{.status.certificate}' | base64 -d > ~/.kube/users/jenkins-bot.crt

echo "✅ CSRs approved and certificates downloaded"