pipeline {
    agent any
    
    tools {
        maven 'M3'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build & Test') {
            steps {
                echo '🚀 Construction du projet Maven...'
                sh 'mvn clean compile test'
            }
        }
        
        stage('Package') {
            steps {
                echo '📦 Génération du JAR...'
                sh 'mvn package -DskipTests'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline Maven exécutée avec succès!'
        }
    }
}
