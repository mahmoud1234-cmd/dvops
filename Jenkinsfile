pipeline {
    agent any

    environment {
        // Met à jour cet ID avec ton credential GitHub valide
        GIT_CREDENTIALS = 'nouvel-id-github'
        IMAGE_NAME = 'mahmoud/test-jenkins'
        IMAGE_TAG = '1.0'
    }

    triggers {
        githubPush()  // Déclenche le build à chaque push sur GitHub
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Récupération du projet privé depuis GitHub..."
                git branch: 'main',
                    credentialsId: "${env.GIT_CREDENTIALS}",
                    url: 'https://github.com/mahmoud1234-cmd/dvops'
            }
        }

        stage('Build / Package') {
            steps {
                echo "🔧 Génération du livrable Maven..."
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo "📦 Archivage du livrable dans target/"
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Création de l'image Docker..."
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "🚀 Push de l'image vers DockerHub..."
                sh """
                    echo 'dckr_pat_CaQ1tkxUPG6cPF2KDxEXEbXnw44' | docker login -u mahmoud340 --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker logout
                """
            }
        }

    }

    post {
        failure {
            echo "❌ Build échoué, envoi de l'email..."
            emailext(
                subject: "Build Jenkins ÉCHOUÉ !",
                body: """
Bonjour,

Le build Jenkins a échoué.
Job : ${env.JOB_NAME}
Build : #${env.BUILD_NUMBER}

Consultez Jenkins pour plus de détails.

Cordialement.
""",
                to: "mahmoudhasnaoui223@gmail.com"
            )
        }

        success {
            echo "✅ Pipeline terminé avec succès !"
        }
    }
}
