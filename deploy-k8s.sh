#!/bin/bash

# Configuration
NAMESPACE="tp-projet-2025"
IMAGE_TAG="latest"
KUBE_CONTEXT="minikube"

echo "🚀 Déploiement Kubernetes pour TP-Projet-2025..."

# Vérifier que kubectl est installé
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl n'est pas installé"
    exit 1
fi

# Vérifier la connexion au cluster
echo "🔍 Vérification du cluster Kubernetes..."
kubectl config use-context $KUBE_CONTEXT
kubectl cluster-info

# Créer le namespace
echo "📁 Création du namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Appliquer les configurations
echo "📋 Application des configurations..."

# 1. ConfigMap
kubectl apply -f configmap.yaml -n $NAMESPACE

# 2. Déploiement (mise à jour de l'image)
cat deployment.yaml | sed "s|votredockerhub/tp-projet-2025:latest|votredockerhub/tp-projet-2025:$IMAGE_TAG|g" | kubectl apply -n $NAMESPACE -f -

# 3. Service
kubectl apply -f service.yaml -n $NAMESPACE

# 4. Ingress (si nécessaire)
if [ -f ingress.yaml ]; then
    kubectl apply -f ingress.yaml -n $NAMESPACE
fi

# Attendre le déploiement
echo "⏳ Attente du déploiement..."
kubectl rollout status deployment/tp-projet-deployment -n $NAMESPACE --timeout=300s

# Afficher les informations
echo "✅ Déploiement terminé avec succès!"
echo ""
echo "📊 RÉSUMÉ DU DÉPLOIEMENT:"
echo "========================="
kubectl get all -n $NAMESPACE
echo ""
echo "🌐 SERVICES:"
kubectl get service -n $NAMESPACE
echo ""
echo "📝 LOGS:"
echo "kubectl logs deployment/tp-projet-deployment -n $NAMESPACE"
echo ""
echo "🔍 DÉTAILS:"
echo "kubectl describe deployment tp-projet-deployment -n $NAMESPACE"
echo ""
echo "🌍 ACCÈS À L'APPLICATION:"
SERVICE_TYPE=$(kubectl get service tp-projet-service -n $NAMESPACE -o jsonpath='{.spec.type}')
if [ "$SERVICE_TYPE" = "LoadBalancer" ]; then
    IP=$(kubectl get service tp-projet-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -z "$IP" ]; then
        IP=$(kubectl get service tp-projet-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    fi
    echo "URL: http://$IP"
elif [ "$SERVICE_TYPE" = "NodePort" ]; then
    NODE_PORT=$(kubectl get service tp-projet-service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
    echo "NodePort: http://localhost:$NODE_PORT"
    echo "Pour accéder: kubectl port-forward svc/tp-projet-service 8080:80 -n $NAMESPACE"
fi
