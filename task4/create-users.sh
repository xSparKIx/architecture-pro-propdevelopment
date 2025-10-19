#!/bin/bash

echo "👤 Creating Kubernetes users with absolute paths..."

HOME_DIR="$HOME"
KUBE_USER_DIR="$HOME_DIR/.kube/users"

# Переходим в директорию с сертификатами
cd "$KUBE_USER_DIR"

echo "📁 Creating certificates in: $(pwd)"

# Пользователь 1: developer - Иван Петров
openssl genrsa -out ivan.petrov.key 2048
openssl req -new -key ivan.petrov.key -out ivan.petrov.csr -subj "/CN=ivan.petrov/O=developers"

# Пользователь 2: security-auditor - Анна Сидорова
openssl genrsa -out anna.sidorova.key 2048
openssl req -new -key anna.sidorova.key -out anna.sidorova.csr -subj "/CN=anna.sidorova/O=security"

# Пользователь 3: ci-bot - Jenkins service account
openssl genrsa -out jenkins-bot.key 2048
openssl req -new -key jenkins-bot.key -out jenkins-bot.csr -subj "/CN=jenkins-bot/O=ci"

echo "✅ User certificates created in $KUBE_USER_DIR"
ls -la *.key *.csr