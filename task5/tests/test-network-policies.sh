#!/bin/bash

echo "🎯 Final Network Policy Test..."

echo "📋 Current Network Policies:"
kubectl get networkpolicies

echo ""
echo "1. ✅ Testing ALLOWED: front-end → back-end-api"
kubectl run final-test-1 --rm -i -t --image=alpine --labels role=front-end --restart=Never -- sh -c "
  if wget -qO- --timeout=5 http://back-end-api-app > /dev/null 2>&1; then
    echo '✅ SUCCESS: Connection allowed (correct)'
  else
    echo '❌ FAILED: Connection blocked (wrong)'
  fi
"

echo ""
echo "2. ✅ Testing ALLOWED: admin-front-end → admin-back-end-api"
kubectl run final-test-2 --rm -i -t --image=alpine --labels role=admin-front-end --restart=Never -- sh -c "
  if wget -qO- --timeout=5 http://admin-back-end-api-app > /dev/null 2>&1; then
    echo '✅ SUCCESS: Connection allowed (correct)'
  else
    echo '❌ FAILED: Connection blocked (wrong)'
  fi
"

echo ""
echo "3. ❌ Testing BLOCKED: front-end → admin-back-end-api"
kubectl run final-test-3 --rm -i -t --image=alpine --labels role=front-end --restart=Never -- sh -c "
  if wget -qO- --timeout=3 http://admin-back-end-api-app > /dev/null 2>&1; then
    echo '❌ FAILED: Connection allowed (should be blocked!)'
  else
    echo '✅ SUCCESS: Connection blocked (correct)'
  fi
"

echo ""
echo "4. ❌ Testing BLOCKED: unknown pod → back-end-api"
kubectl run final-test-4 --rm -i -t --image=alpine --labels app=unknown --restart=Never -- sh -c "
  if wget -qO- --timeout=3 http://back-end-api-app > /dev/null 2>&1; then
    echo '❌ FAILED: Connection allowed (should be blocked!)'
  else
    echo '✅ SUCCESS: Connection blocked (correct)'
  fi
"

echo "🎉 Final test completed!"