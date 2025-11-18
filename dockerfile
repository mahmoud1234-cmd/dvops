# Dockerfile
FROM openjdk:17-jdk-slim

# Installer Maven pour la construction
RUN apt-get update && apt-get install -y maven && apt-get clean

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers du projet
COPY . .

# Construire l'application avec Maven
RUN mvn clean package -DskipTests

# Exposer le port
EXPOSE 9090

# Commande pour lancer l'application
ENTRYPOINT ["java", "-jar", "target/*.jar"]
