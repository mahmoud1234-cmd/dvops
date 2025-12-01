#!/bin/bash
echo "🚀 CONSTRUCTION MANUELLE DU PROJET"

# Construction Maven
echo "=== BUILD MAVEN ==="
docker run --rm -v $(pwd):/app -w /app maven:3.9.9 mvn clean compile -DskipTests

# Construction Docker
echo "=== BUILD DOCKER ==="
docker build -t mahmoud340/student-management:latest .

# Test
echo "=== TEST IMAGE ==="
docker run --rm mahmoud340/student-management:latest java -version

echo "✅ CONSTRUCTION TERMINÉE !"
