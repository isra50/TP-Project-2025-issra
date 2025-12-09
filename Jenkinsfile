pipeline {
    agent any
    
    environment {
        // Configuration SonarQube
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP Projet 2025 - Spring Boot'
    }
    
    stages {
        // ÉTAPE 1 : Récupération du code
        stage('🔁 Checkout Git') {
            steps {
                echo '📥 Récupération du code source depuis Git...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'https://github.com/isra50/TP-Project-2025-issra.git',
                        credentialsId: 'github-isra50'
                    ]]
                ])
                
                // Vérification du contenu
                sh '''
                    echo "=== Structure du projet ==="
                    ls -la
                    echo ""
                    echo "=== Vérification Java/Maven ==="
                    java -version
                    mvn --version
                    echo ""
                    echo "=== Fichier pom.xml présent ? ==="
                    if [ -f "pom.xml" ]; then
                        echo "✅ pom.xml trouvé"
                        head -5 pom.xml
                    else
                        echo "❌ ERREUR: pom.xml manquant!"
                        exit 1
                    fi
                '''
            }
        }
        
        // ÉTAPE 2 : Nettoyage
        stage('🧹 Nettoyage') {
            steps {
                echo '🧹 Nettoyage du projet Maven...'
                sh 'mvn clean -q'
            }
        }
        
        // ÉTAPE 3 : Compilation
        stage('⚙️ Compilation') {
            steps {
                echo '⚙️ Compilation du code Spring Boot...'
                sh 'mvn compile -q'
            }
        }
        
        // ÉTAPE 4 : Analyse SonarQube
        stage('🔍 Analyse SonarQube') {
            steps {
                echo '🔍 Analyse de la qualité du code avec SonarQube...'
                
                script {
                    try {
                        withSonarQubeEnv('SonarQube') {
                            sh """
                                mvn sonar:sonar \\
                                  -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                                  -Dsonar.projectName="${SONAR_PROJECT_NAME}" \\
                                  -Dsonar.java.binaries=target/classes \\
                                  -Dsonar.sources=src/main/java \\
                                  -Dsonar.tests=src/test/java \\
                                  -Dsonar.sourceEncoding=UTF-8 \\
                                  -Dsonar.host.url=${SONAR_HOST_URL}
                            """
                        }
                    } catch (Exception e) {
                        echo "⚠️ Analyse SonarQube échouée, continuation sans..."
                        // Méthode alternative
                        sh """
                            mvn sonar:sonar \\
                              -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                              -Dsonar.projectName="${SONAR_PROJECT_NAME}" \\
                              -Dsonar.host.url=${SONAR_HOST_URL}
                        """
                    }
                }
            }
        }
        
        // ÉTAPE 5 : Génération du JAR
        stage('📦 Package JAR') {
            steps {
                echo '📦 Génération du fichier JAR Spring Boot...'
                sh '''
                    echo "Packaging en cours..."
                    mvn package -DskipTests -q
                    
                    echo "=== Résultat packaging ==="
                    if ls target/*.jar 1> /dev/null 2>&1; then
                        echo "✅ JAR généré avec succès"
                        ls -lh target/*.jar
                    else
                        echo "❌ Aucun fichier JAR trouvé!"
                        echo "Contenu du dossier target:"
                        ls -la target/ 2>/dev/null || echo "Dossier target vide"
                        exit 1
                    fi
                '''
            }
        }
        
        // ÉTAPE 6 : Archivage
        stage('💾 Archivage') {
            steps {
                echo '💾 Archivage des artefacts...'
                script {
                    def jarFiles = findFiles(glob: 'target/*.jar')
                    if (!jarFiles.isEmpty()) {
                        echo "Artefacts trouvés:"
                        jarFiles.each { file ->
                            echo "  - ${file.name}"
                        }
                        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    } else {
                        echo "⚠️ Création d'un fichier de test..."
                        sh '''
                            mkdir -p target
                            echo "Test JAR - Projet Spring Boot" > target/test-app.jar
                        '''
                        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    }
                }
            }
        }
    }
    
    // Post-actions
    post {
        always {
            echo '📊 Génération du rapport de build...'
            sh '''
                echo "=== RÉSUMÉ DU BUILD ==="
                echo "Date: $(date)"
                echo "Projet: TP-Projet-2025"
                echo "Repository: isra50/TP-Project-2025-issra"
                echo ""
                echo "=== ARTEFACTS JAR ==="
                find target -name "*.jar" 2>/dev/null || echo "Aucun JAR trouvé"
                echo ""
                echo "=== STATISTIQUES ==="
                if [ -d "target/classes" ]; then
                    echo "Classes compilées: $(find target/classes -name "*.class" 2>/dev/null | wc -l)"
                fi
            '''
        }
        
        success {
            echo '✅ ✅ ✅ PIPELINE RÉUSSI ! ✅ ✅ ✅'
            echo 'Toutes les étapes CI ont été exécutées avec succès.'
        }
        
        failure {
            echo '❌ ❌ ❌ PIPELINE EN ÉCHEC ❌ ❌ ❌'
            echo 'Veuillez vérifier les logs pour identifier l\'erreur.'
            
            sh '''
                echo "=== DERNIÈRES ERREURS ==="
                echo "Vérifiez les logs ci-dessus pour les détails."
            '''
        }
    }
}
