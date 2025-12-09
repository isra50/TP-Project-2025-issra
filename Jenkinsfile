pipeline {
    agent any
    
    // OPTION 1 : Sans section tools (utilise Maven/Java système)
    // OU
    // OPTION 2 : Avec les bons noms d'outils configurés dans Jenkins
    
    stages {
        stage("Checkout Git") {
            steps {
                echo "📥 Récupération du code depuis Git..."
                git branch: "main",
                    url: "https://github.com/isra50/TP-Project-2025-issra.git",
                    credentialsId: "github-isra50"
            }
        }
        
        stage("Nettoyage") {
            steps {
                echo "🧹 Nettoyage du projet..."
                sh "mvn clean"
            }
        }
        
        stage("Compilation") {
            steps {
                echo "⚙️ Compilation du code..."
                sh "mvn compile"
            }
        }
        
        stage("Analyse SonarQube") {
            steps {
                echo "🔍 Analyse qualité avec SonarQube..."
                withSonarQubeEnv("SonarQube") {
                    sh """
                        mvn sonar:sonar \
                          -Dsonar.projectKey=TP-Projet-2025-isra50 \
                          -Dsonar.projectName="TP-Projet-2025-isra50"
                    """
                }
            }
        }
        
        stage("Génération JAR") {
            steps {
                echo "📦 Génération du fichier JAR..."
                sh "mvn package -DskipTests"
            }
        }
        
        stage("Archivage") {
            steps {
                echo "💾 Archivage de l'artefact..."
                archiveArtifacts artifacts: "target/*.jar", fingerprint: true
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline exécuté avec succès !"
        }
        failure {
            echo "❌ Pipeline en échec."
        }
    }
}
