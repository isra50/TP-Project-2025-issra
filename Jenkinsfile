pipeline {
    agent any
    
    environment {
        // Configuration SonarQube
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP-Projet-2025-isra50'
        
        // Chemin Maven (à adapter selon votre installation)
        MAVEN_HOME = '/usr/share/maven'  // Chemin standard sur Ubuntu
        // OU MAVEN_HOME = '/opt/maven'  // Si vous l'avez installé ici
    }
    
    stages {
        stage('🔁 Checkout Code') {
            steps {
                echo '📥 Récupération du code source...'
                // Version simple sans credentials (publique)
                git branch: 'main',
                    url: 'https://github.com/isra50/TP-Project-2025-issra.git'
                
                // Si besoin d'authentification, utilisez:
                // git branch: 'main',
                //     url: 'https://github.com/isra50/TP-Project-2025-issra.git',
                //     credentialsId: 'jenkins-git'  // Utilisez l'ID de votre table
            }
        }
        
        stage('🔧 Vérification Environnement') {
            steps {
                echo '🔧 Vérification des outils installés...'
                script {
                    // Vérifier Java
                    sh '''
                        echo "=== Vérification Java ==="
                        java -version 2>&1 || echo "Java non trouvé"
                        echo ""
                    '''
                    
                    // Vérifier Maven
                    sh '''
                        echo "=== Vérification Maven ==="
                        which mvn || echo "Maven non trouvé dans PATH"
                        echo ""
                    '''
                    
                    // Vérifier SonarQube
                    sh '''
                        echo "=== Vérification SonarQube ==="
                        curl -s http://localhost:9000/api/system/status | grep -q "UP" && echo "✅ SonarQube est UP" || echo "❌ SonarQube n'est pas accessible"
                        echo ""
                    '''
                }
            }
        }
        
        stage('⚙️ Installation Maven (si nécessaire)') {
            steps {
                echo '⚙️ Installation/Configuration de Maven...'
                script {
                    // Essayer plusieurs chemins possibles pour Maven
                    def mvnPaths = [
                        '/usr/bin/mvn',
                        '/usr/local/bin/mvn',
                        '/opt/maven/bin/mvn',
                        '/usr/share/maven/bin/mvn'
                    ]
                    
                    def mvnFound = false
                    for (path in mvnPaths) {
                        def result = sh(script: "which mvn || ls ${path} 2>/dev/null || echo 'not found'", returnStdout: true).trim()
                        if (result != 'not found' && !result.contains('no mvn')) {
                            echo "✅ Maven trouvé à: ${result}"
                            mvnFound = true
                            break
                        }
                    }
                    
                    if (!mvnFound) {
                        echo "⚠️ Maven non trouvé, tentative d'installation..."
                        sh '''
                            # Installation de Maven sur Ubuntu/Debian
                            sudo apt-get update || true
                            sudo apt-get install -y maven || echo "Installation échouée, utilisation de wrapper"
                            
                            # Vérification après installation
                            which mvn && echo "✅ Maven installé avec succès" || echo "❌ Échec installation Maven"
                        '''
                    }
                }
            }
        }
        
        stage('🧹 Clean Project') {
            steps {
                echo '🧹 Nettoyage du projet...'
                sh '''
                    # Utilise mvn du système ou mvn wrapper
                    if command -v mvn &> /dev/null; then
                        mvn clean -q
                    elif [ -f "mvnw" ]; then
                        chmod +x mvnw
                        ./mvnw clean -q
                    else
                        echo "❌ Maven non trouvé et pas de wrapper disponible"
                        exit 1
                    fi
                '''
            }
        }
        
        stage('🔨 Compilation') {
            steps {
                echo '🔨 Compilation du code...'
                sh '''
                    if command -v mvn &> /dev/null; then
                        mvn compile -q
                    elif [ -f "mvnw" ]; then
                        ./mvnw compile -q
                    fi
                '''
            }
        }
        
        stage('🧪 Exécution Tests') {
            steps {
                echo '🧪 Exécution des tests...'
                sh '''
                    if command -v mvn &> /dev/null; then
                        mvn test -q
                    elif [ -f "mvnw" ]; then
                        ./mvnw test -q
                    fi
                '''
                
                // Enregistrement des résultats de tests
                junit 'target/surefire-reports/*.xml'
            }
        }
        
        stage('🔍 Analyse SonarQube') {
            steps {
                echo '🔍 Analyse de qualité avec SonarQube...'
                script {
                    // OPTION 1: Avec token SonarQube (recommandé)
                    withCredentials([string(credentialsId: 'jenkins-sonar', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            if command -v mvn &> /dev/null; then
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=TP-Projet-2025-isra50 \
                                  -Dsonar.projectName="TP-Projet-2025-isra50" \
                                  -Dsonar.host.url=http://localhost:9000 \
                                  -Dsonar.login=${SONAR_TOKEN}
                            elif [ -f "mvnw" ]; then
                                ./mvnw sonar:sonar \
                                  -Dsonar.projectKey=TP-Projet-2025-isra50 \
                                  -Dsonar.projectName="TP-Projet-2025-isra50" \
                                  -Dsonar.host.url=http://localhost:9000 \
                                  -Dsonar.login=${SONAR_TOKEN}
                            fi
                        '''
                    }
                    
                    // OPTION 2: Avec admin/admin (pour test)
                    /*
                    sh '''
                        if command -v mvn &> /dev/null; then
                            mvn sonar:sonar \
                              -Dsonar.projectKey=TP-Projet-2025-isra50 \
                              -Dsonar.projectName="TP-Projet-2025-isra50" \
                              -Dsonar.host.url=http://localhost:9000 \
                              -Dsonar.login=admin \
                              -Dsonar.password=admin
                        elif [ -f "mvnw" ]; then
                            ./mvnw sonar:sonar \
                              -Dsonar.projectKey=TP-Projet-2025-isra50 \
                              -Dsonar.projectName="TP-Projet-2025-isra50" \
                              -Dsonar.host.url=http://localhost:9000 \
                              -Dsonar.login=admin \
                              -Dsonar.password=admin
                        fi
                    '''
                    */
                }
            }
        }
        
        stage('📦 Build JAR') {
            steps {
                echo '📦 Construction du JAR...'
                sh '''
                    if command -v mvn &> /dev/null; then
                        mvn package -DskipTests -q
                    elif [ -f "mvnw" ]; then
                        ./mvnw package -DskipTests -q
                    fi
                '''
                
                // Archive le JAR généré
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                
                // Affiche les informations du JAR
                sh '''
                    echo "=== Fichiers JAR générés ==="
                    ls -la target/*.jar 2>/dev/null || echo "Aucun JAR trouvé"
                    echo ""
                '''
            }
        }
    }
    
    post {
        success {
            echo '✅ ✅ ✅ PIPELINE RÉUSSI ! ✅ ✅ ✅'
            echo "Build #${env.BUILD_NUMBER} terminé avec succès"
            
            // Optionnel: Notification
            // emailext (
            //     subject: "SUCCÈS: Build ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            //     body: "Le pipeline s'est terminé avec succès.\n\nVoir: ${env.BUILD_URL}",
            //     to: 'votre-email@example.com'
            // )
        }
        failure {
            echo '❌ ❌ ❌ PIPELINE ÉCHOUÉ ❌ ❌ ❌'
            echo "Build #${env.BUILD_NUMBER} a échoué"
            
            // Afficher les erreurs détaillées
            sh '''
                echo "=== Dernières erreurs ==="
                echo "Consultez les logs pour plus de détails"
            '''
        }
        always {
            echo '📊 📊 📊 PIPELINE TERMINÉ 📊 📊 📊'
            echo "Temps total: ${currentBuild.durationString}"
            
            // Nettoyage de l'espace de travail (optionnel)
            // cleanWs()
            
            // Rapport de qualité SonarQube
            echo "🔗 Rapport SonarQube: http://localhost:9000/dashboard?id=TP-Projet-2025-isra50"
        }
    }
}
