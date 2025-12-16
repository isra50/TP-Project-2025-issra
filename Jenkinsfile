pipeline {
    agent any
    environment {
        // Configuration Docker
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'votredockerhub/tp-projet-2025'
        DOCKER_TAG = "${BUILD_NUMBER}-${GIT_COMMIT.take(8)}"
        
        // Configuration Kubernetes
        K8S_NAMESPACE = 'tp-projet-2025'
        K8S_CONTEXT = 'minikube' // ou votre contexte k8s
        
        // Configuration SonarQube
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        
        // Configuration Java
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:/usr/local/bin:${PATH}"
    }
    
    stages {
        // ... [vos stages existants: Checkout, Setup, Clean, SonarQube, Build] ...
        
        stage('🐳 Build Docker Image') {
            steps {
                script {
                    echo '🐳 Construction de l’image Docker...'
                    sh """
                        docker build \
                          --build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                          --build-arg COMMIT_SHA=${GIT_COMMIT} \
                          --build-arg VERSION=${DOCKER_TAG} \
                          -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                          -t ${DOCKER_IMAGE}:latest \
                          .
                    """
                }
            }
        }
        
        stage('📤 Push to Docker Registry') {
            steps {
                script {
                    echo '📤 Pousser l’image vers Docker Registry...'
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        sh """
                            echo "${DOCKER_PASSWORD}" | docker login -u ${DOCKER_USERNAME} --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
        
        stage('⚙️ Prepare Kubernetes Manifests') {
            steps {
                script {
                    echo '⚙️ Préparation des fichiers de déploiement Kubernetes...'
                    
                    // Créer le répertoire k8s s'il n'existe pas
                    sh 'mkdir -p k8s'
                    
                    // Générer les fichiers YAML avec les variables d'environnement
                    sh """
                        cat > k8s/deployment.yaml << EOF
                        $(sed "s/\${BUILD_NUMBER}/${BUILD_NUMBER}/g; s/\${GIT_COMMIT}/${GIT_COMMIT}/g; s/votredockerhub\\/tp-projet-2025:latest/${DOCKER_IMAGE}:${DOCKER_TAG}/g" deployment-template.yaml)
                        EOF
                        
                        cat > k8s/service.yaml << 'EOF'
                        $(cat service.yaml)
                        EOF
                        
                        cat > k8s/configmap.yaml << 'EOF'
                        $(cat configmap.yaml)
                        EOF
                    """
                }
            }
        }
        
        stage('🚀 Deploy to Kubernetes') {
            steps {
                script {
                    echo '🚀 Déploiement sur Kubernetes...'
                    
                    withCredentials([
                        file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')
                    ]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG}
                            
                            echo "1. Vérification du contexte Kubernetes..."
                            kubectl config current-context
                            
                            echo "2. Création du namespace s'il n'existe pas..."
                            kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                            
                            echo "3. Déploiement de l'application..."
                            kubectl apply -f k8s/ -n ${K8S_NAMESPACE}
                            
                            echo "4. Vérification du déploiement..."
                            kubectl rollout status deployment/tp-projet-deployment -n ${K8S_NAMESPACE} --timeout=300s
                            
                            echo "5. Affichage des ressources déployées..."
                            kubectl get all -n ${K8S_NAMESPACE}
                            
                            echo "6. Affichage du service..."
                            kubectl get service tp-projet-service -n ${K8S_NAMESPACE}
                        """
                    }
                }
            }
        }
        
        stage('🧪 Smoke Tests') {
            steps {
                script {
                    echo '🧪 Tests de fumée...'
                    
                    withCredentials([
                        file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')
                    ]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG}
                            
                            echo "1. Récupération de l'URL du service..."
                            SERVICE_URL=\$(kubectl get service tp-projet-service -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                            if [ -z "\$SERVICE_URL" ]; then
                                SERVICE_URL=\$(kubectl get service tp-projet-service -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                            fi
                            
                            if [ -n "\$SERVICE_URL" ]; then
                                echo "2. Test de l'endpoint health..."
                                curl -f http://\${SERVICE_URL}/actuator/health || exit 1
                                
                                echo "3. Test de l'endpoint info..."
                                curl -s http://\${SERVICE_URL}/actuator/info | grep -q 'build' || echo "⚠️ Endpoint info non standard"
                            else
                                echo "ℹ️ Service non exposé publiquement, création d'un port-forward..."
                                kubectl port-forward svc/tp-projet-service 8080:80 -n ${K8S_NAMESPACE} &
                                sleep 5
                                curl -f http://localhost:8080/actuator/health || exit 1
                                pkill -f "kubectl port-forward"
                            fi
                        """
                    }
                }
            }
        }
        
        stage('📊 Post-Deployment Verification') {
            steps {
                script {
                    echo '📊 Vérification post-déploiement...'
                    
                    sh """
                        echo "=== RAPPORT DE DÉPLOIEMENT ==="
                        echo "📦 Application: TP-Projet-2025"
                        echo "🏷️ Version: ${DOCKER_TAG}"
                        echo "🐳 Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        echo "☸️ Namespace: ${K8S_NAMESPACE}"
                        echo "📊 Build: #${BUILD_NUMBER}"
                        echo "🔗 Commit: ${GIT_COMMIT}"
                        echo "✅ Déploiement Kubernetes terminé avec succès"
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Nettoyage...'
            sh '''
                docker system prune -f || true
                rm -rf k8s || true
            '''
            cleanWs()
        }
        success {
            script {
                echo "🎉 DÉPLOIEMENT RÉUSSI 🎉"
                echo "📊 Dashboard: kubectl get all -n ${K8S_NAMESPACE}"
                echo "📝 Logs: kubectl logs deployment/tp-projet-deployment -n ${K8S_NAMESPACE}"
            }
        }
        failure {
            script {
                echo "❌ DÉPLOIEMENT ÉCHOUÉ"
                echo "🔍 Dépannage:"
                echo "kubectl describe deployment tp-projet-deployment -n ${K8S_NAMESPACE}"
                echo "kubectl logs deployment/tp-projet-deployment -n ${K8S_NAMESPACE}"
            }
        }
    }
}
