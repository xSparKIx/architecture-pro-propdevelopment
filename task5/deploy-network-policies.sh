#!/bin/bash

echo "🎯 Deploying network policies..."

echo "1. Applying non-admin API policies..."
kubectl apply -f non-admin-api-allow.yaml

echo "2. Applying admin API policies..."
kubectl apply -f admin-api-allow.yaml

echo "3. Applying default deny-all policy..."
kubectl apply -f deny-all.yaml

echo ""
echo "📋 Applied network policies:"
kubectl get networkpolicies

echo "✅ Network policies deployed!"