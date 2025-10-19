#!/bin/bash

echo "🎯 Demonstrating RBAC is working correctly..."

echo ""
echo "1. Creating test resources in default namespace..."
kubectl create deployment nginx-test --image=nginx --replicas=2
kubectl create service clusterip nginx-test --tcp=80:80

echo ""
echo "2. Testing ivan.petrov (developer) access..."
kubectl --context=ivan.petrov-context get pods
kubectl --context=ivan.petrov-context get deployments
kubectl --context=ivan.petrov-context get services

echo ""
echo "3. Testing anna.sidorova (security-auditor) cross-namespace access..."
kubectl --context=anna.sidorova-context get pods -n kube-system | head -3

echo ""
echo "4. Testing jenkins-bot (ci-bot) deployment access..."
kubectl --context=jenkins-bot-context get deployments

echo ""
echo "5. Demonstrating security restrictions..."
echo "   Developer CANNOT access nodes:"
kubectl --context=ivan.petrov-context get nodes 2>&1 | head -1

echo "   Developer CANNOT access other namespaces:"
kubectl --context=ivan.petrov-context get pods -n kube-system 2>&1 | head -1

echo "   CI-bot CANNOT access secrets:"
kubectl --context=jenkins-bot-context get secrets 2>&1 | head -1