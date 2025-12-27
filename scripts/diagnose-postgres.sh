#!/bin/bash

echo "=========================================="
echo "Diagnostic des Conteneurs PostgreSQL"
echo "=========================================="
echo ""

echo "1. Vérification des conteneurs PostgreSQL..."
docker-compose ps | grep postgres

echo ""
echo "2. Logs de postgres-auth:"
docker-compose logs --tail=50 postgres-auth

echo ""
echo "3. Logs de postgres-project:"
docker-compose logs --tail=50 postgres-project

echo ""
echo "4. Logs de postgres-validation:"
docker-compose logs --tail=50 postgres-validation

echo ""
echo "5. Logs de postgres-finance:"
docker-compose logs --tail=50 postgres-finance

echo ""
echo "6. Vérification des ports utilisés:"
netstat -tuln | grep -E "5432|5433|5434|5435|5436" || echo "Aucun port PostgreSQL trouvé"

echo ""
echo "7. Vérification des volumes:"
docker volume ls | grep postgres

echo ""
echo "=========================================="
echo "Diagnostic terminé"
echo "=========================================="

