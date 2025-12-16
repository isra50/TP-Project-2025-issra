pipeline {
    agent any
    environment {
        // Configuration Docker
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'votredockerhub/tp-projet-2025'
        DOCKER_TAG = "${BUILD_NUMBER}"
        
        // Configuration SonarQube
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP Projet 2025 - Spring Boot'
        
        // Configuration Java
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${PATH}"
    }
    stages {
        stage('📥 Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('🐳 Build Docker Image') {
            steps {
                script {
                    echo '🐳 Construction de l’image Docker...'
                    sh """
                        docker build \
                          --build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                          --build-arg COMMIT_SHA=\$(git rev-parse HEAD) \
                          -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                          -t ${DOCKER_IMAGE}:latest \
                          .
                    """
                }
            }
        }
        
        stage('🔍 SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'jenkins-sonar', variable: 'SONAR_TOKEN')]) {
                    sh """
                        mvn sonar:sonar \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONAR_TOKEN} \
                          -DskipTests
                    """
                }
            }
        }
        
        stage('🧪 Test Image Locally') {
            steps {
                script {
                    echo '🧪 Test de l’image Docker en local...'
                    sh """
                        docker run -d -p 8081:8080 --name tp-projet-test ${DOCKER_IMAGE}:${DOCKER_TAG}
                        sleep 15
                        curl -f http://localhost:8081/actuator/health || exit 1
                        docker stop tp-projet-test
                        docker rm tp-projet-test
                    """
                }
            }
        }
        
        stage('📤 Push to Docker Registry') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo '📤 Pousser l’image vers Docker Registry...'
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        sh """
                            docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            sh 'docker system prune -f'
            cleanWs()
        }
        success {
            echo "✅ Image Docker disponible: ${DOCKER_IMAGE}:${DOCKER_TAG}"
        }
    }
}
