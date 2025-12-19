#!/bin/bash

# Script de test automatisé pour les API
# Prérequis : jq installé (sudo apt-get install jq)

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Tests des Microservices R&D"
echo "=========================================="
echo ""

# Fonction pour afficher le résultat
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Test 1: Health Check Gateway
echo "1. Test Health Check Gateway..."
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/actuator/health")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "200" ]; then
    print_result 0 "Gateway est accessible"
else
    print_result 1 "Gateway non accessible (HTTP $HTTP_CODE)"
    exit 1
fi
echo ""

# Test 2: Register
echo "2. Test Inscription..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser'$(date +%s)'","email":"test'$(date +%s)'@example.com","password":"password123"}')
if echo "$REGISTER_RESPONSE" | grep -q "accessToken"; then
    TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.accessToken')
    USER_ID=$(echo "$REGISTER_RESPONSE" | jq -r '.userId')
    print_result 0 "Inscription réussie (User ID: $USER_ID)"
else
    print_result 1 "Échec de l'inscription"
    echo "Réponse: $REGISTER_RESPONSE"
    exit 1
fi
echo ""

# Test 3: Login
echo "3. Test Connexion..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"researcher1","password":"password123"}')
if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.accessToken')
    print_result 0 "Connexion réussie"
else
    print_result 1 "Échec de la connexion"
    echo "Réponse: $LOGIN_RESPONSE"
    # Utiliser le token de l'inscription précédente
    echo -e "${YELLOW}Utilisation du token d'inscription${NC}"
fi
echo ""

# Test 4: Créer un projet
echo "4. Test Création Projet..."
PROJECT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/projects" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title":"Projet Test","description":"Description du projet test"}')
if echo "$PROJECT_RESPONSE" | grep -q "id"; then
    PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.id')
    print_result 0 "Projet créé (ID: $PROJECT_ID)"
else
    print_result 1 "Échec de la création du projet"
    echo "Réponse: $PROJECT_RESPONSE"
    exit 1
fi
echo ""

# Test 5: Lister les projets
echo "5. Test Liste Projets..."
PROJECTS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/projects" \
  -H "Authorization: Bearer $TOKEN")
if echo "$PROJECTS_RESPONSE" | grep -q "id"; then
    PROJECT_COUNT=$(echo "$PROJECTS_RESPONSE" | jq '. | length')
    print_result 0 "Liste des projets récupérée ($PROJECT_COUNT projets)"
else
    print_result 1 "Échec de la récupération des projets"
fi
echo ""

# Test 6: Créer un budget
echo "6. Test Création Budget..."
BUDGET_RESPONSE=$(curl -s -X POST "$BASE_URL/api/finance/budgets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"projectId\":$PROJECT_ID,\"allocatedAmount\":50000.00,\"currency\":\"EUR\",\"fiscalYear\":2024}")
if echo "$BUDGET_RESPONSE" | grep -q "id"; then
    BUDGET_ID=$(echo "$BUDGET_RESPONSE" | jq -r '.id')
    print_result 0 "Budget créé (ID: $BUDGET_ID)"
else
    print_result 1 "Échec de la création du budget"
    echo "Réponse: $BUDGET_RESPONSE"
fi
echo ""

# Test 7: Créer une dépense
if [ ! -z "$BUDGET_ID" ]; then
    echo "7. Test Création Dépense..."
    EXPENSE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/finance/expenses" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{\"projectId\":$PROJECT_ID,\"budgetId\":$BUDGET_ID,\"amount\":5000.00,\"description\":\"Test expense\",\"category\":\"EQUIPMENT\"}")
    if echo "$EXPENSE_RESPONSE" | grep -q "id"; then
        print_result 0 "Dépense créée"
    else
        print_result 1 "Échec de la création de la dépense"
        echo "Réponse: $EXPENSE_RESPONSE"
    fi
    echo ""
fi

# Test 8: Vérifier le budget mis à jour
if [ ! -z "$BUDGET_ID" ]; then
    echo "8. Test Vérification Budget..."
    UPDATED_BUDGET=$(curl -s -X GET "$BASE_URL/api/finance/budgets/$BUDGET_ID" \
      -H "Authorization: Bearer $TOKEN")
    SPENT=$(echo "$UPDATED_BUDGET" | jq -r '.spentAmount')
    if [ "$SPENT" != "null" ] && [ "$SPENT" != "0" ]; then
        print_result 0 "Budget mis à jour (Dépensé: $SPENT EUR)"
    else
        print_result 1 "Budget non mis à jour"
    fi
    echo ""
fi

echo "=========================================="
echo -e "${GREEN}Tous les tests sont terminés${NC}"
echo "=========================================="

