agent any

    environment {
        // Configuration SonarQube
        SONAR_HOST_URL    = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'TP-Projet-2025-isra50'
        SONAR_PROJECT_NAME = 'TP Projet 2025 - Spring Boot'

        // Configuration Java
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${PATH}"
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
                        credentialsId: 'jenkins-git'
                    ]]
                ])
            }
        }

        stage('🔧 Setup Environment') {
            steps {
                echo '🔧 Configuration de l’environnement de build...'
                sh '''
                    echo "=== Vérification Java ==="
                    java -version

                    echo "=== Vérification Maven ==="
                    if command -v mvn &> /dev/null; then
                        echo "✅ Maven est installé"
                        mvn -version
                    else
                        echo "⚠️ Maven non trouvé"
                        exit 1
                    fi

                    echo "=== Vérification SonarQube ==="
                    curl -s --connect-timeout 5 "${SONAR_HOST_URL}/api/system/status" \
                        | grep -q "UP" && echo "✅ SonarQube accessible" || echo "⚠️ SonarQube non accessible"
                '''
            }
        }

        stage('🧹🔨 Clean & Compile Project') {
            steps {
                echo '🧹🔨 Nettoyage et compilation du projet...'
                sh 'mvn clean compile -q'
            }
        }

        stage('🔍 SonarQube Analysis') {
            steps {
                echo '🔍 Analyse de qualité avec SonarQube...'
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
                        echo "⚠️ Analyse SonarQube échouée : ${e.message}"
                        echo "➡️ Le pipeline continue..."
                    }
                }
            }
        }

        stage('📦 Build & Package') {
            steps {
                echo '📦 Construction du fichier JAR...'
                sh '''
                    mvn package -DskipTests -q

                    echo "=== JAR généré ==="
                    ls -lh target/*.jar || (echo "❌ Aucun JAR généré" && exit 1)
                '''

                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('✅ Verify & Report') {
            steps {
                echo '✅ Vérification finale et rapport...'
                sh '''
                    echo "=== RAPPORT FINAL ==="
                    echo "📦 Projet : ${SONAR_PROJECT_NAME}"
                    echo "🔑 Clé Sonar : ${SONAR_PROJECT_KEY}"
                    echo "🌐 SonarQube : ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
                    echo "📁 Artefact : target/*.jar"
                    echo "✅ Build #${BUILD_NUMBER} terminé avec succès"
                '''
            }
        }
    }

    post {
        success {
            echo '🎉 PIPELINE RÉUSSI 🎉'
            echo "📦 Artefacts : ${BUILD_URL}artifact/"
            echo "🔗 SonarQube : ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
        }

        failure {
            echo '❌ PIPELINE ÉCHOUÉ'
            echo "🔍 Logs : ${BUILD_URL}console"
        }

        always {
            echo '📊 PIPELINE TERMINÉ'
            echo "⏱️ Durée : ${currentBuild.durationString}"
            echo "📈 Statut : ${currentBuild.currentResult}"
        }
    }
}
