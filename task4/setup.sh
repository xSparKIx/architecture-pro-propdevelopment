#!/bin/bash

echo "🎯 Setting up Kubernetes RBAC..."

# Запускаем все скрипты по порядку
./start-minikube.sh
./create-users.sh
./approve-csrs.sh
./apply-roles.sh
./apply-roles-bindings.sh
./setup-user-kubeconfig.sh

echo "🎉 RBAC setup completed successfully!"
echo ""
echo "📋 Available contexts:"
echo "   - ivan.petrov-context (developer)"
echo "   - anna.sidorova-context (security-auditor)" 
echo "   - jenkins-bot-context (ci-bot)"
echo ""
echo "💡 Usage example: kubectl --context=ivan.petrov-context get pods"

./tests/run.sh