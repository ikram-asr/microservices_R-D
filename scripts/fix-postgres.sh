#!/bin/bash

echo "=========================================="
echo "Correction des Problèmes PostgreSQL"
echo "=========================================="
echo ""

echo "1. Arrêt de tous les conteneurs..."
docker-compose down

echo ""
echo "2. Suppression des volumes PostgreSQL (optionnel - décommenter si nécessaire)..."
# docker volume rm miroservicesrd_postgres-auth-data
# docker volume rm miroservicesrd_postgres-project-data
# docker volume rm miroservicesrd_postgres-validation-data
# docker volume rm miroservicesrd_postgres-finance-data
# docker volume rm miroservicesrd_keycloak-db-data

echo ""
echo "3. Vérification des ports..."
echo "Ports PostgreSQL utilisés:"
netstat -tuln | grep -E "5432|5433|5434|5435|5436" || echo "Aucun port PostgreSQL en conflit"

echo ""
echo "4. Redémarrage des conteneurs PostgreSQL uniquement..."
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance keycloak-db

echo ""
echo "5. Attente que les bases soient prêtes (30 secondes)..."
sleep 30

echo ""
echo "6. Vérification du statut..."
docker-compose ps | grep postgres

echo ""
echo "7. Test de connexion..."
docker-compose exec postgres-auth pg_isready -U auth_user || echo "postgres-auth non prêt"
docker-compose exec postgres-project pg_isready -U project_user || echo "postgres-project non prêt"

echo ""
echo "=========================================="
echo "Correction terminée"
echo "=========================================="

