#!/bin/bash

# Script pour tester les APIs

echo "=========================================="
echo "Test des APIs - R&D Microservices"
echo "=========================================="
echo ""

BASE_URL="http://localhost:8080"
TOKEN=""

# 1. Test d'inscription
echo "1. Test d'inscription..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "testuser@example.com",
    "password": "password123"
  }')

if [ $? -eq 0 ]; then
    echo "✓ Inscription réussie"
    TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.token')
    echo "Token obtenu: ${TOKEN:0:20}..."
else
    echo "✗ Échec de l'inscription"
    exit 1
fi

echo ""

# 2. Test de login
echo "2. Test de login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }')

if [ $? -eq 0 ]; then
    echo "✓ Login réussi"
    TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
else
    echo "✗ Échec du login"
fi

echo ""

# 3. Test de validation du token
echo "3. Test de validation du token..."
VALIDATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/validate" \
  -H "Authorization: Bearer $TOKEN")

if [ "$VALIDATE_RESPONSE" = "true" ]; then
    echo "✓ Token valide"
else
    echo "✗ Token invalide"
fi

echo ""

# 4. Test de création de projet
echo "4. Test de création de projet..."
PROJECT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/projects" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "nom": "Projet Test",
    "description": "Description du projet test",
    "statut": "DRAFT"
  }')

if [ $? -eq 0 ]; then
    PROJECT_ID=$(echo $PROJECT_RESPONSE | jq -r '.id')
    echo "✓ Projet créé avec ID: $PROJECT_ID"
else
    echo "✗ Échec de création du projet"
    PROJECT_ID=1
fi

echo ""

# 5. Test de liste des projets
echo "5. Test de liste des projets..."
PROJECTS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/projects" \
  -H "Authorization: Bearer $TOKEN")

if [ $? -eq 0 ]; then
    PROJECT_COUNT=$(echo $PROJECTS_RESPONSE | jq '. | length')
    echo "✓ Liste des projets obtenue ($PROJECT_COUNT projets)"
else
    echo "✗ Échec de récupération des projets"
fi

echo ""

# 6. Test de création de validation
echo "6. Test de création de validation..."
VALIDATION_RESPONSE=$(curl -s -X POST "$BASE_URL/api/validations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"idProject\": $PROJECT_ID,
    \"nomTest\": \"Test de validation\",
    \"statut\": \"PENDING\"
  }")

if [ $? -eq 0 ]; then
    VALIDATION_ID=$(echo $VALIDATION_RESPONSE | jq -r '.id')
    echo "✓ Validation créée avec ID: $VALIDATION_ID"
else
    echo "✗ Échec de création de validation"
fi

echo ""

# 7. Test de création de budget
echo "7. Test de création de budget..."
BUDGET_RESPONSE=$(curl -s -X POST "$BASE_URL/api/finance/budgets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"idProject\": $PROJECT_ID,
    \"montant\": 50000.00
  }")

if [ $? -eq 0 ]; then
    BUDGET_ID=$(echo $BUDGET_RESPONSE | jq -r '.id')
    echo "✓ Budget créé avec ID: $BUDGET_ID"
else
    echo "✗ Échec de création de budget"
fi

echo ""

echo "=========================================="
echo "Tests terminés !"
echo "=========================================="
