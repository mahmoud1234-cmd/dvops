#!/bin/bash
echo "🎯 CONFIGURATION AUTOMATIQUE GRAFANA"
echo "===================================="

# Attendre que Grafana soit prêt
echo "⏳ Attente que Grafana soit complètement prêt..."
for i in {1..10}; do
    if curl -s http://localhost:3000/api/health 2>/dev/null | grep -q "database"; then
        echo "✅ Grafana prêt après $i secondes"
        break
    fi
    echo "Essai $i/10..."
    sleep 3
done

# Configuration via API
echo ""
echo "📊 Configuration de la source de données Prometheus..."

# Créer le payload JSON
CONFIG_JSON='{
  "name": "Prometheus",
  "type": "prometheus",
  "access": "proxy",
  "url": "http://prometheus-service:9090",
  "isDefault": true,
  "jsonData": {
    "timeInterval": "15s",
    "queryTimeout": "60s",
    "httpMethod": "POST"
  }
}'

# Essayer de configurer via API
echo "Tentative de configuration via API..."
RESPONSE=$(curl -s -X POST http://localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d "$CONFIG_JSON" \
  -u admin:admin 2>/dev/null)

if echo "$RESPONSE" | grep -q "Datasource added"; then
    echo "✅ Source de données Prometheus configurée via API"
else
    echo "⚠️  Configuration automatique échouée"
    echo "   Configuration manuelle requise :"
    echo "   1. Allez sur http://localhost:3000"
    echo "   2. Configuration → Data Sources → Add data source"
    echo "   3. Sélectionnez Prometheus"
    echo "   4. URL: http://prometheus-service:9090"
    echo "   5. Save & Test"
fi

echo ""
echo "📋 RÉCAPITULATIF :"
echo "   • Grafana: http://localhost:3000"
echo "   • Prometheus: http://localhost:9090"
echo "   • Application: http://localhost:8080"
echo "   • SonarQube: http://localhost:9000"
