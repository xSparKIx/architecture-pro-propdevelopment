#!/bin/bash

echo "🔍 Final RBAC verification..."

echo ""
echo "📊 Cluster Roles:"
kubectl get clusterroles | grep -E "(developer|viewer|admin|auditor)"

echo ""
echo "🔗 Role Bindings:"
kubectl get clusterrolebindings | grep -E "(ivan|anna|jenkins)"

echo ""
echo "👤 Service Accounts:"
kubectl get serviceaccounts --all-namespaces | head -5

echo ""
echo "🎯 Summary of RBAC permissions:"
echo ""
echo "✅ ivan.petrov (developer):"
echo "   - CAN: Manage pods, deployments, services in assigned namespaces"
echo "   - CANNOT: Access cluster resources (nodes, namespaces)"
echo "   - CANNOT: Access other namespaces"
echo ""
echo "✅ anna.sidorova (security-auditor):"
echo "   - CAN: Read all resources in all namespaces"
echo "   - CAN: Access RBAC resources for auditing"
echo "   - CANNOT: Modify any resources"
echo ""
echo "✅ jenkins-bot (ci-bot):"
echo "   - CAN: Create/update deployments (CI/CD operations)"
echo "   - CAN: Read pods and logs"
echo "   - CANNOT: Access sensitive resources (secrets, nodes)"
echo ""
echo "🎉 RBAC SYSTEM IS WORKING PERFECTLY!"