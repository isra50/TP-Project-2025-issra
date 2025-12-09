pipeline {
    agent any
    
    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP-Projet-2025-isra50'
    }
    
    stages {
        stage('🔁 Checkout Git') {
            steps {
                echo '📥 Récupération du code...'
                // Version simple sans credential (pour test)
                git branch: 'main',
                    url: 'https://github.com/isra50/TP-Project-2025-issra.git'
                // OU avec credential
                // git branch: 'main',
                //     url: 'https://github.com/isra50/TP-Project-2025-issra.git',
                //     credentialsId: 'jenkins-git'
            }
        }
        
        stage('🔍 Test SonarQube Connection') {
            steps {
                echo '🔍 Test de connexion à SonarQube...'
                script {
                    // Testez d'abord la connexion
                    def sonarStatus = sh(
                        script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/api/system/status',
                        returnStdout: true
                    ).trim()
                    
                    echo "Status SonarQube: ${sonarStatus}"
                    
                    if (sonarStatus == "200") {
                        echo "✅ SonarQube est accessible"
                    } else {
                        error "❌ SonarQube n'est pas accessible. Status: ${sonarStatus}"
                    }
                }
            }
        }
        
        stage('🧹 Nettoyage') {
            steps {
                echo '🧹 Nettoyage...'
                sh '/opt/maven/bin/mvn clean -q' // Chemin complet si Maven est installé
            }
        }
        
        stage('⚙️ Compilation') {
            steps {
                echo '⚙️ Compilation...'
                sh '/opt/maven/bin/mvn compile -q'
            }
        }
        
        stage('🔍 Analyse SonarQube (avec admin/admin)') {
            steps {
                echo '🔍 Analyse SonarQube avec admin/admin...'
                sh '''
                    /opt/maven/bin/mvn sonar:sonar \
                      -Dsonar.projectKey=TP-Projet-2025-isra50 \
                      -Dsonar.projectName="TP-Projet-2025-isra50" \
                      -Dsonar.host.url=http://localhost:9000 \
                      -Dsonar.login=admin \
                      -Dsonar.password=admin
                '''
            }
        }
        
        stage('📦 Package JAR') {
            steps {
                echo '📦 Génération du JAR...'
                sh '/opt/maven/bin/mvn package -DskipTests -q'
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
