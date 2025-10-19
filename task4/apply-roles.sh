#!/bin/bash

echo "🎭 Applying RBAC roles..."

kubectl apply -f ./scripts/roles.yaml

echo "✅ RBAC roles applied"