#!/bin/bash

echo "🔗 Applying RoleBindings..."

kubectl apply -f ./scripts/roles-bindings.yaml

echo "✅ RoleBindings applied"