#!/bin/bash

# Полное удаление старого minikube
echo "Очищаем старые данные..."
minikube delete

# Запуск нового minikube
echo "Запускаем minikube..."
minikube start

# Создание namespace audit-zone
echo "Создаем namespace..."
kubectl apply -f ./01-create-namespace.yaml

echo "Применяем PodSecurity Admission..."
kubectl label namespace audit-zone \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted \
  --overwrite

echo "Ожидаем запуска namespace..."
sleep 5

echo "=== Запускаем тесты манифестов ==="

# Проходим по всем yaml-файлам рекурсивно
for file in $(find ./insecure-manifests/ -type f -name "*.yaml"); do
  echo "=== Тестируем $file ==="
  if kubectl apply -f "$file" 2>&1 | grep -q "Forbidden"; then
    echo "✅ PodSecurity успешно заблокировал $file"
  else
    # Проверяем, был ли pod создан (не должен был)
    sleep 2
    POD_NAME=$(grep "name:" "$file" | head -1 | awk '{print $2}')
    if kubectl get pod "$POD_NAME" -n audit-zone &> /dev/null; then
      echo "❌ $file не был заблокирован PodSecurity!"
      kubectl delete pod "$POD_NAME" -n audit-zone --ignore-not-found
    else
      echo "✅ PodSecurity успешно заблокировал $file"
    fi
  fi
  echo
done

echo "=== Запускаем тесты исправленных манифестов ==="

for file in $(find ./secure-manifests/ -type f -name "*.yaml"); do
  echo "=== Тестируем $file ==="
  if kubectl apply -f "$file"; then
    echo "✅ Исправленный manifest $file успешно применен"
    # Удаляем успешный pod для очистки
    POD_NAME=$(grep "name:" "$file" | head -1 | awk '{print $2}')
    kubectl delete pod "$POD_NAME" -n audit-zone --ignore-not-found
  else
    echo "❌ Исправленный manifest $file был заблокирован"
  fi
  echo
done
 
echo "📋 Тесты завершены!"