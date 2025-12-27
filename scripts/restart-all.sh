#!/bin/bash

# Script pour redémarrer tous les services à zéro

echo "=========================================="
echo "Redémarrage Complet des Services"
echo "=========================================="
echo ""

# 1. Arrêter tous les conteneurs
echo "1. Arrêt de tous les conteneurs..."
docker-compose down
echo "✓ Conteneurs arrêtés"
echo ""

# 2. Optionnel : Supprimer les volumes (décommenter si nécessaire)
echo "2. Pour supprimer les volumes et données, décommenter les lignes suivantes:"
# docker volume rm miroservicesrd_postgres-auth-data
# docker volume rm miroservicesrd_postgres-project-data
# docker volume rm miroservicesrd_postgres-validation-data
# docker volume rm miroservicesrd_postgres-finance-data
# docker volume rm miroservicesrd_keycloak-db-data
# docker volume rm miroservicesrd_prometheus-data
# docker volume rm miroservicesrd_grafana-data
# docker volume rm miroservicesrd_elasticsearch-data
echo ""

# 3. Nettoyer les images (optionnel)
echo "3. Nettoyage des images non utilisées..."
docker system prune -f
echo "✓ Nettoyage terminé"
echo ""

# 4. Vérifier que le réseau existe
echo "4. Vérification du réseau Docker..."
if ! docker network ls | grep -q "rd-network"; then
    echo "Création du réseau rd-network..."
    docker network create rd-network
    echo "✓ Réseau créé"
else
    echo "✓ Réseau existe déjà"
fi
echo ""

# 5. Build des images
echo "5. Build des images Docker..."
docker-compose build --no-cache
echo "✓ Build terminé"
echo ""

# 6. Démarrer les bases de données d'abord
echo "6. Démarrage des bases de données PostgreSQL..."
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance keycloak-db
echo "✓ Bases de données démarrées"
echo ""

# 7. Attendre que les bases soient prêtes
echo "7. Attente que les bases soient prêtes (30 secondes)..."
sleep 30
echo "✓ Attente terminée"
echo ""

# 8. Vérifier les bases de données
echo "8. Vérification des bases de données..."
for container in postgres-auth postgres-project postgres-validation postgres-finance keycloak-db; do
    status=$(docker ps --filter "name=$container" --format "{{.Status}}")
    if [ -n "$status" ]; then
        echo "  ✓ $container : $status"
    else
        echo "  ✗ $container : Non démarré"
    fi
done
echo ""

# 9. Démarrer tous les services
echo "9. Démarrage de tous les services..."
docker-compose up -d
echo "✓ Services démarrés"
echo ""

# 10. Attendre que les services soient prêts
echo "10. Attente que les services soient prêts (20 secondes)..."
sleep 20
echo "✓ Attente terminée"
echo ""

# 11. Vérifier le statut de tous les services
echo "11. Statut de tous les services:"
docker-compose ps
echo ""

# 12. Vérifier les health checks
echo "12. Vérification des health checks..."
echo ""

services=(
    "NGINX Gateway:http://localhost:8085/health"
    "Auth Service:http://localhost:8081/actuator/health"
    "Project Service:http://localhost:8082/actuator/health"
    "Validation Service:http://localhost:8083/actuator/health"
    "Finance Service:http://localhost:8084/actuator/health"
    "Keycloak:http://localhost:8090/health"
    "Prometheus:http://localhost:9090/-/healthy"
    "Grafana:http://localhost:3000/api/health"
)

for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    url=$(echo $service | cut -d: -f2-)
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo "  ✓ $name : OK"
    else
        echo "  ✗ $name : Non accessible"
    fi
done

echo ""
echo "=========================================="
echo "Redémarrage terminé !"
echo "=========================================="
echo ""
echo "URLs des services:"
echo "  - NGINX Gateway: http://localhost:8085"
echo "  - Auth Service: http://localhost:8081"
echo "  - Project Service: http://localhost:8082"
echo "  - Validation Service: http://localhost:8083"
echo "  - Finance Service: http://localhost:8084"
echo "  - Keycloak: http://localhost:8090"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000"
echo ""
echo "Pour tester les APIs, voir API_TESTING_GUIDE.md"

