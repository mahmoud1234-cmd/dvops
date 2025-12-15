#!/bin/bash
echo "🔍 Vérification des port-forwards..."
echo "=================================="

echo ""
echo "1. Processus actifs :"
ps aux | grep "kubectl port-forward" | grep -v grep || echo "Aucun port-forward actif"

echo ""
echo "2. Test de connectivité :"
echo "   Prometheus (9090):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:9090 2>/dev/null && echo "   ✅ Accessible" || echo "   ❌ Non accessible"
echo "   Grafana (3000):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null && echo "   ✅ Accessible" || echo "   ❌ Non accessible"
echo "   Application (8080):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null && echo "   ✅ Accessible" || echo "   ❌ Non accessible"
echo "   SonarQube (9000):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 2>/dev/null && echo "   ✅ Accessible" || echo "   ❌ Non accessible"

echo ""
echo "3. Logs disponibles :"
ls -la /tmp/*.log 2>/dev/null | grep -E "(prometheus|grafana|spring|sonar)" || echo "Aucun log trouvé"
