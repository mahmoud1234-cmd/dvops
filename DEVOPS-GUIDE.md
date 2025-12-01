# Guide DevOps - Construction Manuelle

## Problème Identifié
Le conteneur Jenkins n'a pas accès à Docker et ne peut pas exécuter les outils directement.

## Solution : Construction Manuelle

### Étape 1 : Construction Maven
cd /var/jenkins_home/workspace/student-management
docker run --rm -v $(pwd):/app -w /app maven:3.9.9 mvn clean compile -DskipTests

### Étape 2 : Construction Docker
docker build -t mahmoud340/student-management:latest .

### Étape 3 : Test de l'image
docker run --rm mahmoud340/student-management:latest java -version

### Étape 4 : Analyse SonarQube
docker run --rm -v $(pwd):/app -w /app maven:3.9.9 mvn sonar:sonar -Dsonar.projectKey=student-management-app -Dsonar.host.url=http://localhost:9000 -Dsonar.login=admin -Dsonar.password=admin

## Commandes Rapides
# Tout en une commande
chmod +x build-manuel.sh sonar-analysis.sh
./build-manuel.sh
./sonar-analysis.sh

## URLs Importantes
- Jenkins: http://localhost:9090
- SonarQube: http://localhost:9000
- DockerHub: https://hub.docker.com/r/mahmoud340/student-management

## Architecture Accomplie
- CI/CD: Jenkins Pipeline configuré
- Build: Maven via Docker
- Qualité: SonarQube intégré
- Conteneurisation: Dockerfile généré
- Documentation: Guides complets

---
*Généré automatiquement par le pipeline DevOps*
