#!/bin/bash

echo "🔄 Redeploying with fixed network policies..."

echo "1. Cleaning up existing resources..."
kubectl delete pod,service -l role=front-end 2>/dev/null || true
kubectl delete pod,service -l role=back-end-api 2>/dev/null || true
kubectl delete pod,service -l role=admin-front-end 2>/dev/null || true
kubectl delete pod,service -l role=admin-back-end-api 2>/dev/null || true
kubectl delete networkpolicies --all 2>/dev/null || true

echo "2. Creating services..."
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80

echo "⏳ Waiting for pods to start..."
sleep 15

echo "3. Applying fixed network policies..."
kubectl apply -f ./manifests/non-admin-api-allow.yaml
kubectl apply -f ./manifests/admin-api-allow.yaml
kubectl apply -f ./manifests/deny-all.yaml

echo "📋 Applied network policies:"
kubectl get networkpolicies

echo "4. Testing..."
./tests/test-network-policies.sh

echo "✅ Fixed deployment completed!"