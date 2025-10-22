#!/bin/bash

# Останавливаем и удаляем старый кластер
minikube stop
minikube delete --all --purge

mkdir -p ~/.minikube/files/etc/ssl/certs

cat <<EOF > ~/.minikube/files/etc/ssl/certs/audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Все действия с критическими ресурсами (полный запрос/ответ)
  - level: RequestResponse
    verbs: ["create", "delete", "update", "patch", "get", "list"]
    resources:
      - group: ""
        resources: ["pods", "secrets", "configmaps", "serviceaccounts"]
      - group: "rbac.authorization.k8s.io"
        resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]

  # Метаданные остальных ресурсов
  - level: Metadata
    resources:
      - group: ""
        resources: ["*"]
EOF

# Доделать вывод логов в файл
minikube start \
  --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=-

echo "Minikube с аудитом запущен!"

echo "Запускаем симуляцию инцидента"

bash ./simulate_incident.sh

echo "Сохраняем логи"
kubectl logs kube-apiserver-minikube -n  kube-system | grep audit.k8s.io/v1 > audit.log

echo "Запускаем фильтр логов"
bash ./filter-audit.sh