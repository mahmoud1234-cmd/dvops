pipeline {
    agent any
    
    tools {
        maven 'M3'
    }
    
    stages {
        stage('Check Maven') {
            steps {
                echo '🔍 Vérification de Maven...'
                sh 'mvn --version'
                sh 'ls -la'
            }
        }
        
        stage('Simple Build') {
            steps {
                echo '🏗️ Construction simple...'
                sh 'mvn clean compile'
            }
        }
    }
}
