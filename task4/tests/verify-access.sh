#!/bin/bash

echo "🔍 Verifying user access..."

HOME_DIR="$HOME"

echo "1. Testing ivan.petrov (developer)..."
kubectl --context=ivan.petrov-context get pods -n default

echo "2. Testing anna.sidorova (security-auditor)..."
kubectl --context=anna.sidorova-context get pods --all-namespaces

echo "3. Testing jenkins-bot (ci-bot)..."
kubectl --context=jenkins-bot-context get deployments -n default

echo "4. Testing forbidden actions..."
echo "   Developer trying to get nodes (should fail):"
kubectl --context=ivan.petrov-context get nodes 2>&1 | head -1

echo "✅ Access verification completed"