pipeline {
    agent any
    
    environment {
        // Configuration SonarQube
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP Projet 2025 - Spring Boot'
        
        // Configuration Java (optionnel)
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
    }
    
    stages {
        stage('📥 Checkout Code') {
            steps {
                echo '📥 Récupération du code source depuis GitHub...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/isra50/TP-Project-2025-issra.git',
                        credentialsId: 'jenkins-git'  // Utilise le credential de votre table
                    ]]
                ])
            }
        }
        
        stage('🔧 Setup Environment') {
            steps {
                echo '🔧 Configuration de l environnement de build...'
                script {
                    // Vérification et installation de Maven si nécessaire
                    sh '''
                        echo "=== Vérification des outils ==="
                        
                        # Java
                        java -version || echo "Java non trouvé"
                        
                        # Maven
                        if command -v mvn &> /dev/null; then
                            echo "✅ Maven est installé"
                            mvn --version
                        else
                            echo "⚠️ Installation de Maven..."
                            sudo apt-get update -y
                            sudo apt-get install -y maven
                            mvn --version || echo "Échec d'installation de Maven"
                        fi
                        
                        # Vérification SonarQube
                        echo "=== Vérification SonarQube ==="
                        curl -s --connect-timeout 5 "${SONAR_HOST_URL}/api/system/status" | grep -q "UP" && echo "✅ SonarQube accessible" || echo "⚠️ SonarQube non accessible"
                    '''
                }
            }
        }
        
        stage('🧹 Clean Project') {
            steps {
                echo '🧹 Nettoyage du projet...'
                sh 'mvn clean -q'
            }
        }
        
        stage('🔨 Compile Project') {
            steps {
                echo '🔨 Compilation du code source...'
                sh 'mvn compile -q'
            }
        }
        
        stage('🔍 SonarQube Analysis') {
            steps {
                echo '🔍 Analyse de qualité avec SonarQube...'
                script {
                    try {
                        // Option 1: Avec le credential 'jenkins-sonar' (recommandé)
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
                        
                        // Option 2: Avec admin/admin (pour test - décommentez si besoin)
                        /*
                        sh """
                            mvn sonar:sonar \
                              -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                              -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                              -Dsonar.host.url=${SONAR_HOST_URL} \
                              -Dsonar.login=admin \
                              -Dsonar.password=admin \
                              -Dsonar.java.binaries=target/classes \
                              -DskipTests
                        """
                        */
                    } catch (Exception e) {
                        echo "⚠️ Analyse SonarQube échouée: ${e.message}"
                        echo "Continuer avec le build..."
                    }
                }
            }
        }
        
        stage('📦 Build & Package') {
            steps {
                echo '📦 Construction du fichier JAR...'
                sh '''
                    # Construction sans exécution des tests (à cause de la base de données)
                    mvn package -DskipTests -q
                    
                    # Vérification du JAR généré
                    echo "=== Fichiers JAR générés ==="
                    find target -name "*.jar" -type f | xargs ls -lh 2>/dev/null || echo "Aucun JAR trouvé"
                    
                    # Vérification basique du JAR
                    if ls target/*.jar 1> /dev/null 2>&1; then
                        echo "✅ JAR généré avec succès"
                        jar tf target/*.jar | grep -E "(META-INF/MANIFEST.MF|BOOT-INF)" | head -5
                    else
                        echo "❌ Erreur: Aucun JAR généré"
                        exit 1
                    fi
                '''
                
                // Archivage du JAR pour téléchargement
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
        
        stage('✅ Verify & Report') {
            steps {
                echo '✅ Vérification finale et génération de rapports...'
                sh '''
                    echo "=== RAPPORT DE BUILD ==="
                    echo "📊 Projet: ${SONAR_PROJECT_NAME}"
                    echo "🔑 Clé: ${SONAR_PROJECT_KEY}"
                    echo "🌐 SonarQube: ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
                    echo "📦 Artefact: target/*.jar"
                    echo "✅ Build #${BUILD_NUMBER} terminé avec succès!"
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 🎉 🎉 PIPELINE RÉUSSI ! 🎉 🎉 🎉'
            echo "Build #${env.BUILD_NUMBER} complété avec succès"
            echo "📦 Télécharger le JAR: ${env.BUILD_URL}artifact/"
            echo "🔗 Rapport SonarQube: ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
            
            // Optionnel: Envoyer une notification
            // emailext (
            //     subject: "SUCCÈS: Build ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            //     body: "Le pipeline s'est terminé avec succès.\n\nVoir: ${env.BUILD_URL}",
            //     to: 'email@example.com'
            // )
        }
        failure {
            echo '❌ ❌ ❌ PIPELINE ÉCHOUÉ ❌ ❌ ❌'
            echo "Build #${env.BUILD_NUMBER} a échoué"
            echo "🔍 Détails: ${env.BUILD_URL}console"
            
            // Optionnel: Notification d'échec
            // emailext (
            //     subject: "ÉCHEC: Build ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            //     body: "Le pipeline a échoué.\n\nVoir: ${env.BUILD_URL}",
            //     to: 'email@example.com'
            // )
        }
        always {
            echo '📊 📊 📊 PIPELINE TERMINÉ 📊 📊 📊'
            echo "⏱️  Durée totale: ${currentBuild.durationString}"
            echo "🔗 URL du build: ${env.BUILD_URL}"
            echo "📈 Statut final: ${currentBuild.currentResult}"
            
            // Nettoyage (optionnel - décommentez si nécessaire)
            // cleanWs()
        }
    }
}
