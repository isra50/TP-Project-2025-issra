# Stage 1: Build stage avec Maven et JDK 17 (identique à votre Jenkins)
FROM maven:3.8.6-openjdk-17 AS builder

# Métadonnées
LABEL maintainer="isra50"
LABEL stage="builder"
LABEL version="1.0"
LABEL description="Build stage pour TP Projet 2025 - Spring Boot"

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de configuration Maven (optimisation du cache Docker)
COPY pom.xml ./
COPY mvnw ./
COPY .mvn/ .mvn/

# Télécharger les dépendances (cette étape est mise en cache)
RUN mvn dependency:go-offline -B -q

# Copier le code source
COPY src ./src

# Variables d'environnement pour la build
ENV SONAR_HOST_URL=http://localhost:9000
ENV SONAR_PROJECT_KEY=TP-Projet-2025-isra50
ENV MAVEN_OPTS="-DskipTests"

# Exécuter les étapes de build similaires à votre Jenkinsfile
RUN echo "📥 Configuration de l’environnement de build..." && \
    echo "=== Vérification Java ===" && \
    java -version && \
    echo "=== Vérification Maven ===" && \
    mvn -version

# Nettoyage et compilation (étape Jenkins: Clean & Compile)
RUN echo "🧹🔨 Nettoyage et compilation du projet..." && \
    mvn clean compile -q

# Construction du package (étape Jenkins: Build & Package)
RUN echo "📦 Construction du fichier JAR..." && \
    mvn package -DskipTests -q && \
    echo "=== JAR généré ===" && \
    ls -lh target/*.jar

# Stage 2: Runtime stage léger avec JRE seulement
FROM openjdk:17-jre-slim

# Métadonnées
LABEL maintainer="isra50"
LABEL stage="runtime"
LABEL version="1.0"
LABEL description="Runtime pour TP Projet 2025 - Spring Boot"

# Installer curl pour les health checks
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# Définir le répertoire de travail
WORKDIR /app

# Variables d'environnement pour le runtime
ENV SPRING_PROFILES_ACTIVE=production
ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENV TZ=Europe/Paris

# Copier le JAR depuis le stage builder
COPY --from=builder /app/target/*.jar app.jar

# Exposer le port Spring Boot standard
EXPOSE 8080

# Health check pour vérifier si l'application fonctionne
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Point d'entrée pour exécuter l'application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
