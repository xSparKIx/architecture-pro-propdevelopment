#!/bin/bash

echo "🧪 Testing RBAC with actual resources..."

# Создаем тестовый namespace
kubectl create namespace test-rbac --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "1. Creating test deployment..."
kubectl create deployment test-app --image=nginx --replicas=2 -n test-rbac

echo ""
echo "2. Testing user permissions..."

echo "   👤 ivan.petrov (developer) in test-rbac namespace:"
kubectl --context=ivan.petrov-context get pods -n test-rbac 2>&1 | head -2

echo ""
echo "   👩‍💼 anna.sidorova (security-auditor) in test-rbac namespace:"
kubectl --context=anna.sidorova-context get pods -n test-rbac

echo ""
echo "   🤖 jenkins-bot (ci-bot) in test-rbac namespace:"
kubectl --context=jenkins-bot-context get deployments -n test-rbac

echo ""
echo "3. Testing namespace isolation..."
echo "   Developer CANNOT access kube-system:"
kubectl --context=ivan.petrov-context get pods -n kube-system 2>&1 | head -1

# Убираем тестовые ресурсы
kubectl delete namespace test-rbac 2>&1 | grep -v "Warning"