pipeline {
    agent any

    environment {
        SONAR_HOST_URL     = 'http://localhost:9000'
        SONAR_PROJECT_KEY  = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP Projet 2025 - Spring Boot'

        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH      = "${JAVA_HOME}/bin:${PATH}"

        DOCKER_IMAGE = 'isra50/tp-projet-2025'
        DOCKER_TAG   = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Récupération du code source depuis GitHub...'
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                echo 'Configuration de l’environnement de build...'
                sh '''
                    echo "=== Vérification Java ==="
                    java -version
                    
                    echo "=== Vérification Maven ==="
                    if command -v mvn &> /dev/null; then
                        echo "Maven est installé"
                        mvn -version
                    else
                        echo "Maven non trouvé"
                        exit 1
                    fi
                    
                    echo "=== Vérification Docker ==="
                    docker --version
                    
                    echo "=== Vérification SonarQube ==="
                    curl -s --connect-timeout 5 "${SONAR_HOST_URL}/api/system/status" | grep -q "UP" && echo "SonarQube accessible" || echo "SonarQube non accessible"
                '''
            }
        }

        stage('Clean & Compile Project') {
            steps {
                echo 'Nettoyage et compilation du projet...'
                sh 'mvn clean compile -q'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Analyse de qualité avec SonarQube...'
                script {
                    try {
                        withCredentials([string(credentialsId: 'jenkins-sonar', variable: 'SONAR_TOKEN')]) {
                            sh """
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                  -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                                  -Dsonar.host.url=${SONAR_HOST_URL} \
                                  -Dsonar.login=${SONAR_TOKEN} \
                                  -Dsonar.java.binaries=target/classes \
                                  -Dsonar.coverage.exclusions=**/test/** \
                                  -DskipTests
                            """
                        }
                    } catch (Exception e) {
                        echo "Analyse SonarQube échouée : ${e.getMessage()}"
                        echo "Le pipeline continue..."
                    }
                }
            }
        }

        stage('Build & Package JAR') {
            steps {
                echo 'Construction du fichier JAR...'
                sh '''
                    mvn package -DskipTests -q
                    echo "=== JAR généré ==="
                    ls -lh target/*.jar
                '''
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Construction de l’image Docker...'
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                    echo "Image construite : ${DOCKER_IMAGE}:${DOCKER_TAG} et :latest"
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pousser l’image sur Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                        echo "${DOCKER_PASSWORD}" | docker login -u ${DOCKER_USERNAME} --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                        echo "Images poussées avec succès sur Docker Hub !"
                    '''
                }
            }
        }

        stage('Rapport Final') {
            steps {
                echo 'Rapport final du build...'
                sh '''
                    echo "=== RAPPORT FINAL ==="
                    echo "Projet        : ${SONAR_PROJECT_NAME}"
                    echo "SonarQube     : ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
                    echo "Image Docker  : ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    echo "Docker Hub    : https://hub.docker.com/r/${DOCKER_IMAGE}"
                    echo "Build Jenkins : #${BUILD_NUMBER}"
                    echo "Statut        : SUCCESS"
                    echo "===================="
                '''
            }
        }
    }

    post {
        success {
            echo 'PIPELINE RÉUSSI !'
            echo "Image disponible sur : https://hub.docker.com/r/isra50/tp-projet-2025"
        }
        failure {
            echo 'PIPELINE ÉCHOUÉ'
        }
        always {
            echo 'Nettoyage du workspace...'
            cleanWs()
        }
    }
}
