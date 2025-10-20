#!/bin/bash

echo "=== Фильтрация audit.log ==="

# Извлекаем audit.log из minikube
# minikube ssh "sudo cat /var/log/audit.log" > audit.log

echo "1. События доступа к secrets:"
jq 'select(.objectRef.resource=="secrets" and .verb=="get")' audit.log 2>/dev/null || echo "Не найдено"

echo -e "\n2. События kubectl exec в чужие поды:"
jq 'select(.verb=="create" and .objectRef.subresource=="exec")' audit.log 2>/dev/null || echo "Не найдено"

echo -e "\n3. Привилегированные поды:"
jq 'select(.objectRef.resource=="pods" and .requestObject.spec.containers[].securityContext.privileged==true)' audit.log 2>/dev/null || echo "Не найдено"

echo -e "\n4. Удаление или изменение audit policy:"
grep -i 'audit-policy' audit.log || echo "Не найдено"

echo -e "\n5. Создание RoleBindings:"
jq 'select(.objectRef.resource=="rolebindings")' audit.log 2>/dev/null || echo "Не найдено"

# Создаем выжимку
echo -e "\n=== Создание audit-extract.json ==="
{
jq 'select(.objectRef.resource=="secrets" and .verb=="get")' audit.log 2>/dev/null
jq 'select(.verb=="create" and .objectRef.subresource=="exec")' audit.log 2>/dev/null  
jq 'select(.objectRef.resource=="pods" and .requestObject.spec.containers[].securityContext.privileged==true)' audit.log 2>/dev/null
jq 'select(.objectRef.resource=="rolebindings")' audit.log 2>/dev/null
} | jq -s '.' > audit-extract.json

echo "🎉 Фильтрация завершена!"