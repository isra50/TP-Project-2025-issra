pipeline {
    agent any
    
    tools {
        maven 'Maven-3' // Assurez-vous que ce tool est configuré dans Jenkins
        jdk 'JDK-17'    // Assurez-vous que Java 17 est configuré
    }
    
    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP-Projet-2025-isra50' // Nom simplifié pour éviter les problèmes de guillemets
        
        // Utilisez le credential 'jenkins-sonar' de votre table
        SONAR_TOKEN = credentials('jenkins-sonar') // Assurez-vous que ce credential existe
    }
    
    stages {
        stage('🔁 Checkout Git') {
            steps {
                echo '📥 Récupération du code...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/isra50/TP-Project-2025-issra.git',
                        // Utilisez 'jenkins-git' ou 'github-ista' de votre table
                        credentialsId: 'jenkins-git' // Vérifiez l'ID exact
                    ]]
                ])
            }
        }
        
        stage('🧹 Nettoyage et Compilation') {
            steps {
                echo '🧹 Nettoyage et compilation...'
                sh 'mvn clean compile -q'
            }
        }
        
        stage('🔍 Analyse SonarQube') {
            steps {
                echo '🔍 Analyse SonarQube...'
                withCredentials([string(credentialsId: 'jenkins-sonar', variable: 'SONAR_TOKEN')]) {
                    sh """
                        mvn sonar:sonar \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }
        
        stage('🧪 Tests') {
            steps {
                echo '🧪 Exécution des tests...'
                sh 'mvn test -q'
            }
        }
        
        stage('📦 Package JAR') {
            steps {
                echo '📦 Génération du JAR...'
                sh 'mvn package -DskipTests -q'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline réussi !'
        }
        failure {
            echo '❌ Pipeline échoué'
        }
        always {
            echo '📊 Pipeline terminé'
        }
    }
}
