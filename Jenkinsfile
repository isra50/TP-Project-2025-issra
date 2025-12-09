pipeline {
    agent any
    
    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP Projet 2025 - Spring Boot'
        // Ajoutez ces variables si vous avez un token SonarQube
        // SONAR_LOGIN = 'admin'
        // SONAR_PASSWORD = 'admin'
    }
    
    stages {
        stage('🔁 Checkout Git') {
            steps {
                echo '📥 Récupération du code...'
                git branch: 'main',
                    url: 'https://github.com/isra50/TP-Project-2025-issra.git',
                    credentialsId: 'github-isra50'
            }
        }
        
        stage('🧹 Nettoyage') {
            steps {
                echo '🧹 Nettoyage...'
                sh 'mvn clean -q'
            }
        }
        
        stage('⚙️ Compilation') {
            steps {
                echo '⚙️ Compilation...'
                sh 'mvn compile -q'
            }
        }
        
       stage('🔍 Analyse SonarQube') {
    steps {
        echo '🔍 Analyse SonarQube...'
        sh '''
            mvn sonar:sonar \
              -Dsonar.projectKey=TP-Projet-2025-isra50 \
              -Dsonar.projectName="TP Projet 2025 - Spring Boot" \
              -Dsonar.host.url=http://localhost:9000 \
              -Dsonar.login=admin \
              -Dsonar.password=admin
        '''
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
    }
}
