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

# Установка Gatekeeper
echo "Установка OPA Gatekeeper..."
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.15.0/deploy/gatekeeper.yaml

echo "Ожидаем запуска подов Gatekeeper..."
NAMESPACE=gatekeeper-system

# Ожидаем создания namespace
until kubectl get namespace $NAMESPACE &> /dev/null; do
  echo "Ожидание $NAMESPACE namespace..."
  sleep 2
done

# Ожидаем готовности всех подов Gatekeeper
kubectl wait --for=condition=Ready pods --all -n $NAMESPACE --timeout=300s
echo "✅ Поды Gatekeeper запущены"

# Применение ConstraintTemplates
echo "Применение Gatekeeper ConstraintTemplates..."
kubectl apply -f ./gatekeeper/constraint-templates/

# Ожидаем создания CRD
echo "Ожидание подготовки ConstraintTemplate CRDs..."
for crd in k8sdenyprivileged k8sdenyhostpath k8srequirenonroot k8sreadonlyrootfs; do
  echo "Waiting for CRD $crd..."
  until kubectl get crd ${crd}.constraints.gatekeeper.sh &> /dev/null; do
    sleep 3
  done
  echo "✅ CRD ${crd}.constraints.gatekeeper.sh готов"
done

# Даем время для инициализации
echo "Ожидание инициализации ConstraintTemplates..."
sleep 10

# Применение Constraints
echo "Применение Gatekeeper Constraints..."
kubectl apply -f ./gatekeeper/constraints/

# Проверяем constraints
echo "Проверка constraints status..."
kubectl get constraints

echo "Проверка manifests..."

# Проходим по всем yaml-файлам рекурсивно
for file in $(find ./insecure-manifests/ -type f -name "*.yaml"); do
  echo "=== Тестирование $file ==="
  if kubectl apply -f "$file" 2>&1 | grep -E "(denied|error|Error)"; then
    echo "✅ Успешно заблокирован: $file"
  else
    # Проверяем, был ли pod создан (должен быть заблокирован)
    sleep 2
    POD_NAME=$(grep "name:" "$file" | head -1 | awk '{print $2}')
    if kubectl get pod "$POD_NAME" -n audit-zone &> /dev/null; then
      echo "❌ $file не был заблокирован!"
      kubectl delete pod "$POD_NAME" -n audit-zone --ignore-not-found
    else
      echo "✅ Успешно заблокирован $file"
    fi
  fi
  echo
done

echo "Проверка исправленных manifests..."
for file in $(find ./secure-manifests/ -type f -name "*.yaml"); do
  echo "=== Тестирование $file ==="
  if kubectl apply -f "$file"; then
    echo "✅ Успешно применен: $file"
    # Удаляем успешный pod чтобы очистить пространство
    POD_NAME=$(grep "name:" "$file" | head -1 | awk '{print $2}')
    kubectl delete pod "$POD_NAME" -n audit-zone --ignore-not-found
  else
    echo "❌ Ошибка при применение manifest: $file"
  fi
  echo
done

echo "✅ All done!"