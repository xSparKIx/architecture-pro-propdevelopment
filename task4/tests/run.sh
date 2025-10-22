#!/bin/bash

echo "🎯 Run tests..."

# Запускаем все тесты по порядку
./tests/verify-access.sh
./tests/rbac.sh
./tests/with-resources.sh
./tests/verification.sh

echo "✅ Tests completed!"