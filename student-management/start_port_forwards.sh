#!/bin/bash
echo "🌐 Démarrage des port-forwards..."
echo "================================="

# Arrêter les précédents port-forwards
pkill -f "kubectl port-forward" 2>/dev/null
sleep 2

# Démarrer les port-forwards
echo ""
echo "1. 🔧 Prometheus (port 9090)..."
kubectl port-forward -n devops svc/prometheus-service 9090:9090 > /tmp/prometheus-pf.log 2>&1 &
PROM_PID=$!
sleep 2

echo "2. 🎨 Grafana (port 3000)..."
kubectl port-forward -n devops svc/grafana-service 3000:3000 > /tmp/grafana-pf.log 2>&1 &
GRAFANA_PID=$!
sleep 2

echo "3. 📱 Application Spring (port 8080)..."
kubectl port-forward -n devops svc/spring-service 8080:8080 > /tmp/spring-pf.log 2>&1 &
SPRING_PID=$!
sleep 2

echo "4. 📊 SonarQube (port 9000)..."
kubectl port-forward -n devops svc/sonarqube-service 9000:9000 > /tmp/sonar-pf.log 2>&1 &
SONAR_PID=$!
sleep 2

# Vérifier
echo ""
echo "✅ Port-forwards démarrés :"
ps aux | grep "kubectl port-forward" | grep -v grep

echo ""
echo "🔗 URLs d'accès :"
echo "  • Prometheus:  http://localhost:9090"
echo "  • Grafana:     http://localhost:3000"
echo "  • Application: http://localhost:8080"
echo "  • SonarQube:   http://localhost:9000"

echo ""
echo "📋 PIDs des processus :"
echo "  Prometheus:  $PROM_PID"
echo "  Grafana:     $GRAFANA_PID"
echo "  Application: $SPRING_PID"
echo "  SonarQube:   $SONAR_PID"

echo ""
echo "Pour arrêter : ./stop_port_forwards.sh"
echo "Pour vérifier : ./check_port_forwards.sh"
