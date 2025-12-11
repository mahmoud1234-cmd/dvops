# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/student-management-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8089

# Configuration via variables d'environnement
ENV SPRING_DATASOURCE_URL=jdbc:mysql://mysql-service:3306/studentdb
ENV SPRING_DATASOURCE_USERNAME=student
ENV SPRING_DATASOURCE_PASSWORD=student123
ENV SPRING_JPA_HIBERNATE_DDL_AUTO=update
ENV SPRING_JPA_SHOW_SQL=true

ENTRYPOINT ["java", "-jar", "app.jar"]
