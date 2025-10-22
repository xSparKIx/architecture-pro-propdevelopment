#!/bin/bash

echo "⚙️ Setting up user kubeconfig files..."

HOME_DIR="$HOME"
KUBE_USER_DIR="$HOME_DIR/.kube/users"
mkdir -p "$KUBE_USER_DIR"

# Получаем параметры кластера
CLUSTER_NAME="minikube"
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA_CERTIFICATE="$HOME_DIR/.minikube/ca.crt"

echo "🔧 Configuring cluster: $CLUSTER_NAME"
echo "🔧 API Server: $APISERVER"

# Проверяем существование CA сертификата
if [ ! -f "$CA_CERTIFICATE" ]; then
    echo "❌ CA certificate not found at $CA_CERTIFICATE"
    exit 1
fi

# Получаем текущую конфигурацию кластера из minikube
CURRENT_CLUSTER=$(kubectl config view -o jsonpath='{.clusters[?(@.name=="minikube")]}')

if [ -z "$CURRENT_CLUSTER" ]; then
    echo "❌ Minikube cluster not found in kubeconfig"
    exit 1
fi

echo "✅ Found minikube cluster configuration"

# Сначала убедимся, что кластер minikube настроен в основном конфиге
kubectl config set-cluster $CLUSTER_NAME \
  --server=$APISERVER \
  --certificate-authority=$CA_CERTIFICATE \
  --embed-certs=true

# Для developer - Иван Петров
echo "👤 Configuring ivan.petrov..."
kubectl config set-credentials ivan.petrov \
  --client-certificate="$KUBE_USER_DIR/ivan.petrov.crt" \
  --client-key="$KUBE_USER_DIR/ivan.petrov.key" \
  --embed-certs=true

kubectl config set-context ivan.petrov-context \
  --cluster=$CLUSTER_NAME \
  --user=ivan.petrov \
  --namespace=default

# Для security-auditor - Анна Сидорова
echo "👤 Configuring anna.sidorova..."
kubectl config set-credentials anna.sidorova \
  --client-certificate="$KUBE_USER_DIR/anna.sidorova.crt" \
  --client-key="$KUBE_USER_DIR/anna.sidorova.key" \
  --embed-certs=true

kubectl config set-context anna.sidorova-context \
  --cluster=$CLUSTER_NAME \
  --user=anna.sidorova

# Для ci-bot - Jenkins
echo "👤 Configuring jenkins-bot..."
kubectl config set-credentials jenkins-bot \
  --client-certificate="$KUBE_USER_DIR/jenkins-bot.crt" \
  --client-key="$KUBE_USER_DIR/jenkins-bot.key" \
  --embed-certs=true

kubectl config set-context jenkins-bot-context \
  --cluster=$CLUSTER_NAME \
  --user=jenkins-bot

echo "✅ User contexts created in main kubeconfig"

# Создаем отдельные kubeconfig файлы для каждого пользователя
echo "📁 Creating separate kubeconfig files..."

create_user_kubeconfig() {
    local username=$1
    local context="$2-context"
    
    # Создаем новый kubeconfig файл
    cat > "$KUBE_USER_DIR/$username.kubeconfig" << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat $CA_CERTIFICATE | base64 | tr -d '\n')
    server: $APISERVER
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: $username
  name: $context
current-context: $context
kind: Config
preferences: {}
users:
- name: $username
  user:
    client-certificate-data: $(cat "$KUBE_USER_DIR/$username.crt" | base64 | tr -d '\n')
    client-key-data: $(cat "$KUBE_USER_DIR/$username.key" | base64 | tr -d '\n')
EOF

    # Для Ивана добавляем namespace
    if [ "$username" = "ivan.petrov" ]; then
        sed -i 's/context:$/context:\n    namespace: default/' "$KUBE_USER_DIR/$username.kubeconfig"
    fi
    
    echo "   ✅ Created $KUBE_USER_DIR/$username.kubeconfig"
}

create_user_kubeconfig "ivan.petrov" "ivan.petrov"
create_user_kubeconfig "anna.sidorova" "anna.sidorova" 
create_user_kubeconfig "jenkins-bot" "jenkins-bot"

echo "🎉 User kubeconfig setup completed!"
echo ""
echo "📋 Usage examples:"
echo "   kubectl --context=ivan.petrov-context get pods"
echo "   KUBECONFIG=$KUBE_USER_DIR/ivan.petrov.kubeconfig kubectl get pods"