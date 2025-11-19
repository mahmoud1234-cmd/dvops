pipeline {
    agent any

    stages {
        stage('Checkout GitHub') {
            steps {
                echo "🔹 Clonage du projet depuis GitHub"
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/mahmoud1234-cmd/dvops.git',
                        credentialsId: 'github-https-token'
                    ]]
                ])
            }
        }

        stage('Build with Maven') {
            steps {
                echo "🔹 Construction de l'application Spring Boot"
                sh '''
                    if ! command -v mvn &> /dev/null; then
                        echo "📥 Installation de Maven..."
                        curl -L -o maven.tar.gz https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
                        tar -xzf maven.tar.gz -C /tmp/
                        export PATH="/tmp/apache-maven-3.9.9/bin:${PATH}"
                    fi
                    
                    mvn clean package -DskipTests
                    echo "✅ Build Maven réussi !"
                '''
            }
        }

        stage('Generate Docker Commands') {
            steps {
                echo "🔹 Génération des commandes Docker"
                sh '''
                    echo " "
                    echo "🎉 🎉 🎉 FÉLICITATIONS ! 🎉 🎉 🎉"
                    echo "==================================="
                    echo "✅ VOTRE APPLICATION SPRING BOOT EST PRÊTE !"
                    echo " "
                    echo "📦 Fichier JAR généré :"
                    echo "   target/student-management-1.0.0.jar"
                    echo " "
                    echo "🐳 COMMANDES DOCKER À EXÉCUTER MANUELLEMENT :"
                    echo "1. Construire l'image Docker :"
                    echo "   docker build -t mahmoud340/student-management:latest ."
                    echo " "
                    echo "2. Tester l'application :"
                    echo "   docker run -d -p 9090:9090 --name student-app mahmoud340/student-management:latest"
                    echo "   curl http://localhost:9090/"
                    echo " "
                    echo "3. Publier sur DockerHub :"
                    echo "   docker login"
                    echo "   docker push mahmoud340/student-management:latest"
                    echo " "
                    echo "🚀 VOTRE PIPELINE CI EST FONCTIONNEL !"
                    echo "L'application Spring Boot est compilée avec succès."
                '''
            }
        }
    }

    post {
        success {
            echo "✅ PIPELINE RÉUSSI - Application Spring Boot construite !"
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            archiveArtifacts artifacts: 'Dockerfile', fingerprint: true
        }
    }
}
