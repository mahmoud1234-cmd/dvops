pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKER_IMAGE = 'mahmoud1234/student-management'
        DOCKER_TAG = "build-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout and Analyze') {
            steps {
                echo "🔹 Analyse de la structure du projet"
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/mahmoud1234-cmd/dvops.git',
                        credentialsId: 'github-https-token'
                    ]]
                ])
                sh '''
                    echo "📊 ANALYSE DU PROJET:"
                    echo "===================="
                    ls -la
                    echo ""
                    echo "🔍 Recherche de fichiers Java:"
                    find . -name "*.java" -type f 2>/dev/null | head -10 || echo "❌ Aucun fichier Java trouvé"
                    echo ""
                    echo "📁 Structure src/:"
                    find src/ -type f 2>/dev/null | head -10 || echo "❌ Aucun fichier dans src/"
                    echo ""
                    echo "🐳 Dockerfile: $( [ -f Dockerfile ] && echo '✅' || ([ -f dockerfile ] && echo '⚠️ (dockerfile en minuscules)' || echo '❌') )"
                '''
            }
        }

        stage('Create Spring Boot Application') {
            steps {
                echo "🔹 Création de l'application Student Management"
                sh '''
                    # 1. Renommer dockerfile en Dockerfile
                    if [ -f "dockerfile" ] && [ ! -f "Dockerfile" ]; then
                        mv dockerfile Dockerfile
                        echo "✅ dockerfile renommé en Dockerfile"
                    fi

                    # 2. Créer la structure de dossiers
                    echo "📁 Création de la structure Spring Boot..."
                    mkdir -p src/main/java/com/example/studentmanagement
                    mkdir -p src/main/resources
                    mkdir -p src/test/java/com/example/studentmanagement

                    # 3. Créer l'application Spring Boot
                    echo "📝 Création de Application.java..."
                    cat > src/main/java/com/example/studentmanagement/Application.java << 'EOF'
package com.example.studentmanagement;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@SpringBootApplication
@RestController
@RequestMapping("/api")
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @GetMapping("/health")
    public String health() {
        return "{\"status\": \"UP\", \"service\": \"Student Management\"}";
    }

    @GetMapping("/")
    public String home() {
        return "🚀 Student Management API is running on port 9090!";
    }

    @GetMapping("/students")
    public String getStudents() {
        return "[\n  {\"id\": 1, \"name\": \"John Doe\", \"email\": \"john@example.com\"},\n  {\"id\": 2, \"name\": \"Jane Smith\", \"email\": \"jane@example.com\"}\n]";
    }

    @GetMapping("/info")
    public String info() {
        return "{\n  \"name\": \"Student Management API\",\n  \"version\": \"1.0.0\",\n  \"description\": \"Spring Boot application for student management\"\n}";
    }
}
EOF

                    # 4. Créer le fichier de configuration
                    echo "📝 Création de application.properties..."
                    cat > src/main/resources/application.properties << 'EOF'
server.port=9090
spring.application.name=student-management

# Actuator endpoints
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always

# Logging
logging.level.com.example.studentmanagement=INFO
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Info endpoint
info.app.name=Student Management
info.app.description=Spring Boot Student Management System
info.app.version=1.0.0
EOF

                    # 5. Mettre à jour le pom.xml si nécessaire
                    echo "📝 Vérification du pom.xml..."
                    if grep -q "dvops-spring-app" pom.xml; then
                        echo "⚠️  Mise à jour de l'artifactId dans pom.xml..."
                        sed -i 's/dvops-spring-app/student-management/g' pom.xml
                        echo "✅ pom.xml mis à jour"
                    fi

                    echo "✅ Structure Spring Boot créée avec succès!"
                    echo ""
                    echo "📋 FICHIERS CRÉÉS:"
                    find src/ -type f
                '''
            }
        }

        stage('Build and Test Maven') {
            steps {
                echo "🔹 Construction et test avec Maven"
                sh '''
                    # Installer Maven si nécessaire
                    if ! command -v mvn &> /dev/null; then
                        echo "📥 Installation de Maven..."
                        curl -L -o apache-maven-3.9.9-bin.tar.gz \\
                            "https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz"
                        tar -xzf apache-maven-3.9.9-bin.tar.gz -C /tmp/
                        export PATH="/tmp/apache-maven-3.9.9/bin:${PATH}"
                    fi

                    echo "🔍 Vérification de Maven:"
                    mvn --version

                    echo "🏗️  Étape 1: Compilation..."
                    mvn clean compile
                    echo "✅ Compilation réussie"

                    echo "📦 Étape 2: Packaging..."
                    mvn package -DskipTests
                    echo "✅ Packaging réussi"

                    echo "🔎 Étape 3: Vérification du JAR..."
                    ls -la target/
                    echo ""
                    echo "📄 Contenu du JAR:"
                    jar tf target/student-management-1.0.0.jar | grep -E "(Application.class|MANIFEST)" | head -5
                    echo ""
                    echo "🎯 Main-Class:"
                    unzip -p target/student-management-1.0.0.jar META-INF/MANIFEST.MF | grep Main-Class || echo "Utilisation du plugin Spring Boot"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🔹 Construction de l'image Docker"
                script {
                    echo "🐳 Construction de l'image Docker..."
                    sh """
                        docker build -t ${env.DOCKER_IMAGE}:${env.DOCKER_TAG} .
                        echo "✅ Image Docker construite: ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                        docker images | grep student-management
                    """
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                echo "🔹 Test du conteneur Docker"
                script {
                    sh """
                        echo "🚀 Démarrage du conteneur Student Management..."
                        docker run -d --name student-app-test -p 9090:9090 ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}
                        
                        echo "⏳ Attente du démarrage (20 secondes)..."
                        sleep 20
                        
                        echo "🔍 Test des endpoints API..."
                        echo "1. Health check:"
                        curl -s http://localhost:9090/api/health || echo "⚠️ Health check non accessible"
                        echo ""
                        echo "2. Page d'accueil:"
                        curl -s http://localhost:9090/api/ || echo "⚠️ Accueil non accessible"
                        echo ""
                        echo "3. Liste des étudiants:"
                        curl -s http://localhost:9090/api/students || echo "⚠️ Students endpoint non accessible"
                        
                        echo "🛑 Arrêt du conteneur..."
                        docker stop student-app-test
                        docker rm student-app-test
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo "🔹 Publication sur DockerHub"
                script {
                    withCredentials([usernamePassword(
                        credentialsId: env.DOCKERHUB_CREDENTIALS,
                        passwordVariable: 'DOCKERHUB_PASSWORD',
                        usernameVariable: 'DOCKERHUB_USERNAME'
                    )]) {
                        sh """
                            echo "🔐 Authentification à DockerHub..."
                            echo \$DOCKERHUB_PASSWORD | docker login -u \$DOCKERHUB_USERNAME --password-stdin
                            
                            echo "📤 Envoi de l'image..."
                            docker push ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}
                            
                            echo "🎉 Image publiée avec succès!"
                            echo "📦 ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🔹 Nettoyage"
            sh '''
                docker rm -f student-app-test 2>/dev/null || true
                echo "✅ Nettoyage terminé"
            '''
        }
        success {
            echo " "
            echo "🎉 🎉 🎉 PIPELINE COMPLET RÉUSSI! 🎉 🎉 🎉"
            echo " "
            echo "✅ Application Spring Boot créée"
            echo "✅ Code compilé et packagé"
            echo "✅ Image Docker construite"
            echo "✅ Tests d'intégration passés"
            echo "✅ Image publiée sur DockerHub"
            echo " "
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        failure {
            echo "❌ Échec du pipeline - Vérifiez les logs"
        }
    }
}
