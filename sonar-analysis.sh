#!/bin/bash
echo "🔍 ANALYSE SONARQUBE"

docker run --rm -v $(pwd):/app -w /app maven:3.9.9 mvn sonar:sonar -Dsonar.projectKey=student-management-app -Dsonar.host.url=http://localhost:9000 -Dsonar.login=admin -Dsonar.password=admin

echo "✅ ANALYSE TERMINÉE !"
