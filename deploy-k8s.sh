#!/bin/bash

# Configuration
NAMESPACE="tp-projet-2025"
IMAGE_TAG="latest"
KUBE_CONTEXT="minikube"

echo "Déploiement Kubernetes pour TP-Projet-2025..."

# Vérifier que kubectl est installé
if ! command -v kubectl &> /dev/null; then
    echo "kubectl n'est pas installé"
    exit 1
fi

# Vérifier la connexion au cluster
echo "Vérification du cluster Kubernetes..."
kubectl config use-context $KUBE_CONTEXT
kubectl cluster-info

# Créer le namespace
echo "Création du namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Appliquer les configurations du dossier k8s/
echo "Application des configurations..."
kubectl apply -f k8s/ -n $NAMESPACE

# Attendre que les pods soient ready (avec timeout)
echo "Attente du déploiement..."
kubectl wait --for=condition=Available deployment/tp-projet-deployment -n $NAMESPACE --timeout=300s || echo "Warning: Déploiement pas complètement ready (possible CrashLoopBackOff)"

# Affichage des ressources
echo "DÉPLOIEMENT TERMINÉ !"
echo ""
echo "RÉSUMÉ :"
kubectl get all -n $NAMESPACE
echo ""
echo "SERVICES :"
kubectl get service -n $NAMESPACE
echo ""
echo "ACCÈS À L'APPLICATION (méthodes fiables) :"
echo "1. Port-forward (la plus fiable) :"
echo "   kubectl port-forward svc/tp-projet-service 8081:80 -n $NAMESPACE"
echo "   → Ouvrir http://localhost:8081 dans le navigateur"
echo ""
echo "2. Minikube tunnel (pour LoadBalancer) :"
echo "   minikube tunnel"
echo "   → Ouvrir http://127.0.0.1"
echo ""
echo "3. Test healthcheck dans un pod :"
echo "   kubectl get pods -n $NAMESPACE"
echo "   kubectl exec -it <nom-du-pod-running> -- curl http://localhost:8080/actuator/health"
echo ""
echo "LOGS (pour debug) :"
echo "   kubectl logs deployment/tp-projet-deployment -n $NAMESPACE"
