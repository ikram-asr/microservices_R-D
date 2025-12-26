#!/bin/bash

# Script de démarrage rapide pour tester l'application
# Usage: ./quick-start.sh

echo "=========================================="
echo "Démarrage Rapide - Microservices R&D"
echo "=========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080"

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local url=$2
    local data=$3
    local token=$4
    
    if [ -z "$token" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$url" \
            -H "Content-Type: application/json" \
            ${data:+-d "$data"})
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            ${data:+-d "$data"})
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "${GREEN}✓${NC} $method $url (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        return 0
    else
        echo -e "${RED}✗${NC} $method $url (HTTP $http_code)"
        echo "$body"
        return 1
    fi
}

# Test 1: Health Check
echo "1. Test Health Check..."
test_endpoint "GET" "$BASE_URL/actuator/health"
echo ""

# Test 2: Register
echo "2. Test Inscription..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser'$(date +%s)'","email":"test'$(date +%s)'@example.com","password":"password123"}')

if echo "$REGISTER_RESPONSE" | grep -q "accessToken"; then
    TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.accessToken')
    USER_ID=$(echo "$REGISTER_RESPONSE" | jq -r '.userId')
    echo -e "${GREEN}✓${NC} Inscription réussie (User ID: $USER_ID)"
else
    echo -e "${YELLOW}⚠${NC} Tentative de connexion avec utilisateur existant..."
    LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"username":"researcher1","password":"password123"}')
    if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
        TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.accessToken')
        echo -e "${GREEN}✓${NC} Connexion réussie"
    else
        echo -e "${RED}✗${NC} Échec de l'authentification"
        exit 1
    fi
fi
echo ""

# Test 3: Créer un projet
echo "3. Test Création Projet..."
PROJECT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/projects" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"nom":"Projet Test","description":"Description du projet test"}')

if echo "$PROJECT_RESPONSE" | grep -q "idProject"; then
    PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.idProject')
    echo -e "${GREEN}✓${NC} Projet créé (ID: $PROJECT_ID)"
else
    echo -e "${RED}✗${NC} Échec de la création du projet"
    echo "$PROJECT_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Lister les projets
echo "4. Test Liste Projets..."
test_endpoint "GET" "$BASE_URL/api/projects" "" "$TOKEN"
echo ""

# Test 5: Créer un budget
echo "5. Test Création Budget..."
BUDGET_RESPONSE=$(curl -s -X POST "$BASE_URL/api/finance/budgets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"idProject\":$PROJECT_ID,\"montant\":50000.00}")

if echo "$BUDGET_RESPONSE" | grep -q "idBudget"; then
    BUDGET_ID=$(echo "$BUDGET_RESPONSE" | jq -r '.idBudget')
    echo -e "${GREEN}✓${NC} Budget créé (ID: $BUDGET_ID)"
else
    echo -e "${YELLOW}⚠${NC} Échec de la création du budget (peut nécessiter une équipe d'abord)"
fi
echo ""

# Test 6: Créer une équipe
echo "6. Test Création Équipe..."
TEAM_RESPONSE=$(curl -s -X POST "$BASE_URL/api/finance/teams" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"nom":"Équipe Test"}')

if echo "$TEAM_RESPONSE" | grep -q "idTeam"; then
    TEAM_ID=$(echo "$TEAM_RESPONSE" | jq -r '.idTeam')
    echo -e "${GREEN}✓${NC} Équipe créée (ID: $TEAM_ID)"
    
    # Test 7: Créer une dépense
    echo "7. Test Création Dépense..."
    EXPENSE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/finance/expenses" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{\"idProject\":$PROJECT_ID,\"idTeam\":$TEAM_ID,\"montant\":5000.00}")
    
    if echo "$EXPENSE_RESPONSE" | grep -q "idExpense"; then
        echo -e "${GREEN}✓${NC} Dépense créée"
    else
        echo -e "${RED}✗${NC} Échec de la création de la dépense"
    fi
else
    echo -e "${YELLOW}⚠${NC} Échec de la création de l'équipe"
fi
echo ""

# Test 8: Créer une validation
echo "8. Test Création Validation..."
VALIDATION_RESPONSE=$(curl -s -X POST "$BASE_URL/api/validations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"idProject\":$PROJECT_ID,\"nomTest\":\"Test Intégration\",\"statut\":\"PENDING\"}")

if echo "$VALIDATION_RESPONSE" | grep -q "idValidation"; then
    echo -e "${GREEN}✓${NC} Validation créée"
else
    echo -e "${YELLOW}⚠${NC} Échec de la création de la validation"
fi
echo ""

echo "=========================================="
echo -e "${GREEN}Tous les tests sont terminés${NC}"
echo "=========================================="
echo ""
echo "Résumé :"
echo "- Token JWT : $TOKEN"
echo "- Projet ID : $PROJECT_ID"
echo ""
echo "Vous pouvez maintenant tester manuellement les autres endpoints !"

