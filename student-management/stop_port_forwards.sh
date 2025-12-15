#!/bin/bash
echo "🛑 Arrêt de tous les port-forwards..."
pkill -f "kubectl port-forward"
sleep 2
echo "✅ Tous les port-forwards arrêtés"
echo ""
echo "Processus restants :"
ps aux | grep "kubectl port-forward" | grep -v grep || echo "Aucun processus trouvé"
