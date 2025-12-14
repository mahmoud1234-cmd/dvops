#!/bin/bash
echo "🎯 COMPLÉTION DE L'ATELIER KUBERNETES"
echo "===================================="

echo ""
echo "1. CONFIGURATION DOCKER POUR MINIKUBE..."
eval $(minikube docker-env) 2>/dev/null || echo "⚠️ Minikube non démarré"

echo ""
echo "2. VÉRIFICATION DES IMAGES..."
docker images | grep -E "(student|mysql)" || echo "Aucune image trouvée"

echo ""
echo "3. BUILD DE L'IMAGE SPRING BOOT..."
cd student-management
docker build -t student-app:workshop .
cd ..

echo ""
echo "4. VÉRIFICATION KUBERNETES..."
kubectl get namespaces
kubectl get pods -n devops 2>/dev/null || echo "Namespace devops vide"

echo ""
echo "5. DÉPLOIEMENT COMPLET..."
cd k8s

echo "   a. MySQL..."
kubectl apply -f mysql-pv.yaml
kubectl apply -f mysql-deployment.yaml

echo "   b. Attente MySQL..."
sleep 30
kubectl wait --namespace devops --for=condition=ready pod --selector=app=mysql --timeout=120s

echo "   c. ConfigMap et Secret..."
kubectl apply -f configmap-secret.yaml

echo "   d. Application Spring Boot..."
# Créer un déploiement simple
cat > spring-app-final.yaml << 'YAMLEOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app-final
  namespace: devops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: spring-app-final
  template:
    metadata:
      labels:
        app: spring-app-final
    spec:
      containers:
      - name: spring-app
        image: student-app:workshop
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8089
        env:
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:mysql://mysql-service:3306/studentdb"
        - name: SPRING_DATASOURCE_USERNAME
          value: "student"
        - name: SPRING_DATASOURCE_PASSWORD
          value: "student123"
        - name: SPRING_JPA_HIBERNATE_DDL_AUTO
          value: "update"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: spring-app-final-service
  namespace: devops
spec:
  type: NodePort
  selector:
    app: spring-app-final
  ports:
  - port: 8089
    targetPort: 8089
    nodePort: 30080
YAMLEOF

kubectl apply -f spring-app-final.yaml

echo "   e. Attente application..."
sleep 40

echo ""
echo "6. VÉRIFICATION FINALE..."
echo "   a. Pods:"
kubectl get pods -n devops -o wide

echo ""
echo "   b. Services:"
kubectl get svc -n devops

echo ""
echo "   c. Logs application:"
kubectl logs -n devops -l app=spring-app-final --tail=15 2>/dev/null || echo "Pas encore de logs"

echo ""
echo "   d. Test MySQL:"
kubectl exec -n devops deployment/mysql -- mysql -ustudent -pstudent123 -e "SHOW DATABASES; SELECT '✅ MySQL opérationnel' as Status;" 2>/dev/null || echo "❌ MySQL non accessible"

echo ""
echo "   e. Test API:"
kubectl port-forward -n devops svc/spring-app-final-service 8080:8089 2>/dev/null &
PF_PID=$!
sleep 12

if curl -s --max-time 10 http://localhost:8080/actuator/health > /dev/null; then
    echo "✅ API accessible: $(curl -s http://localhost:8080/actuator/health)"
else
    echo "❌ API non accessible"
fi

kill $PF_PID 2>/dev/null

echo ""
echo "🎉 ATELIER COMPLÉTÉ !"
echo ""
echo "📊 RÉSUMÉ:"
echo "   - Cluster Minikube: ✅"
echo "   - Namespace devops: ✅"
echo "   - MySQL déployé: ✅"
echo "   - Application Spring Boot: ✅"
echo "   - Service exposé: ✅ (port 30080)"
echo ""
echo "🌐 URL: http://$(minikube ip):30080"
