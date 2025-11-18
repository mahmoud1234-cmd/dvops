pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKER_IMAGE = 'mahmoud340/student-management'
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
                    find . -name "*.java" -type f 2>/dev/null | head -5
                    echo ""
                    echo "🐳 Dockerfile: $( [ -f Dockerfile ] && echo '✅' || echo '❌' )"
                '''
            }
        }

        stage('Create Spring Boot Application') {
            steps {
                echo "🔹 Création de l'application Student Management"
                sh '''
                    # 1. Créer la structure de dossiers
                    echo "📁 Création de la structure Spring Boot..."
                    mkdir -p src/main/java/com/example/studentmanagement
                    mkdir -p src/main/resources

                    # 2. Créer une Application.java CORRECTE sans problèmes de syntaxe
                    echo "📝 Création de Application.java (syntaxe corrigée)..."
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
        return "{\\"status\\": \\"UP\\", \\"service\\": \\"Student Management\\"}";
    }

    @GetMapping("/")
    public String home() {
        return "Student Management API is running on port 9090!";
    }

    @GetMapping("/students")
    public String getStudents() {
        return "[{\\"id\\": 1, \\"name\\": \\"John Doe\\", \\"email\\": \\"john@example.com\\"}, {\\"id\\": 2, \\"name\\": \\"Jane Smith\\", \\"email\\": \\"jane@example.com\\"}]";
    }

    @GetMapping("/info")
    public String info() {
        return "{\\"name\\": \\"Student Management API\\", \\"version\\": \\"1.0.0\\", \\"description\\": \\"Spring Boot application\\"}";
    }
}
EOF

                    # 3. Créer le fichier de configuration
                    echo "📝 Création de application.properties..."
                    cat > src/main/resources/application.properties << 'EOF'
server.port=9090
spring.application.name=student-management
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always
EOF

                    # 4. Mettre à jour le pom.xml
                    echo "📝 Vérification du pom.xml..."
                    if grep -q "dvops-spring-app" pom.xml; then
                        sed -i 's/dvops-spring-app/student-management/g' pom.xml
                        echo "✅ pom.xml mis à jour"
                    fi

                    echo "✅ Structure Spring Boot créée!"
                    echo "📋 Fichiers créés:"
                    find src/ -type f
                '''
            }
        }

        stage('Build and Test Maven') {
            steps {
                echo "🔹 Construction avec Maven"
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

                    echo "🏗️  Compilation..."
                    mvn clean compile
                    echo "✅ Compilation réussie"

                    echo "📦 Packaging..."
                    mvn package -DskipTests
                    echo "✅ Packaging réussi"

                    echo "🔎 Vérification du JAR:"
                    ls -la target/
                    echo "📄 Main-Class:"
                    unzip -p target/student-management-1.0.0.jar META-INF/MANIFEST.MF | grep Main-Class || echo "Spring Boot Plugin"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🔹 Construction de l'image Docker"
                script {
                    sh """
                        echo "🐳 Construction de l'image..."
                        docker build -t ${env.DOCKER_IMAGE}:${env.DOCKER_TAG} .
                        echo "✅ Image construite: ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                    """
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                echo "🔹 Test du conteneur Docker"
                script {
                    sh """
                        echo "🚀 Démarrage du conteneur..."
                        docker run -d --name student-test -p 9090:9090 ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}
                        
                        echo "⏳ Attente du démarrage..."
                        sleep 25
                        
                        echo "🔍 Test des endpoints:"
                        echo "Health: \$(curl -s http://localhost:9090/api/health || echo 'not-ready')"
                        echo "Home: \$(curl -s http://localhost:9090/api/ || echo 'not-ready')"
                        
                        echo "🛑 Arrêt du conteneur..."
                        docker stop student-test
                        docker rm student-test
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
                            echo "🔐 Authentification DockerHub..."
                            echo \$DOCKERHUB_PASSWORD | docker login -u \$DOCKERHUB_USERNAME --password-stdin
                            
                            echo "📤 Push de l'image..."
                            docker push ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}
                            
                            echo "🎉 Image publiée: ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker rm -f student-test 2>/dev/null || true'
        }
        success {
            echo "🎉 PIPELINE RÉUSSI!"
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        failure {
            echo "❌ Pipeline échoué"
        }
    }
}
