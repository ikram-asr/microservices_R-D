# Guide de Tests - Microservices R&D

## Prérequis pour les Tests

1. Tous les services démarrés (via Docker Compose ou Kubernetes)
2. PostgreSQL accessible
3. Outils : `curl`, `jq` (optionnel pour formatage JSON), ou Postman

## Étape 1 : Démarrer l'Environnement

### Avec Docker Compose

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier que tous les services sont en cours d'exécution
docker-compose ps

# Voir les logs
docker-compose logs -f gateway-service
```

### Avec Kubernetes

```bash
# Vérifier que tous les pods sont prêts
kubectl get pods -n rd-microservices

# Port-forward pour accéder au Gateway
kubectl port-forward svc/gateway-service 8080:8080 -n rd-microservices
```

## Étape 2 : Tests de Santé (Health Checks)

### Vérifier que tous les services répondent

```bash
# Gateway
curl http://localhost:8080/actuator/health

# Auth Service
curl http://localhost:8081/actuator/health

# Project Service
curl http://localhost:8082/actuator/health

# Validation Service
curl http://localhost:8083/actuator/health

# Finance Service
curl http://localhost:8084/actuator/health
```

**Réponse attendue :**
```json
{"status":"UP"}
```

## Étape 3 : Tests Auth-Service

### 3.1. Inscription d'un utilisateur

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "researcher1",
    "email": "researcher1@example.com",
    "password": "password123"
  }'
```

**Réponse attendue :**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "userId": 1,
  "username": "researcher1",
  "role": "RESEARCHER"
}
```

**Sauvegarder le token :**
```bash
# Linux/Mac
export TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Windows PowerShell
$env:TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 3.2. Connexion

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "researcher1",
    "password": "password123"
  }'
```

### 3.3. Créer un utilisateur Admin (optionnel)

Via psql directement dans la base auth_db :
```sql
INSERT INTO users (username, email, password, role) VALUES
('admin', 'admin@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN');
```

Puis se connecter avec admin/password123.

### 3.4. Validation du token

```bash
curl -X POST http://localhost:8080/api/auth/validate \
  -H "Authorization: Bearer $TOKEN"
```

## Étape 4 : Tests Project-Service

### 4.1. Créer un projet

```bash
curl -X POST http://localhost:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Projet Intelligence Artificielle",
    "description": "Recherche sur les algorithmes d'apprentissage automatique"
  }'
```

**Réponse attendue :**
```json
{
  "id": 1,
  "title": "Projet Intelligence Artificielle",
  "description": "Recherche sur les algorithmes d'apprentissage automatique",
  "status": "DRAFT",
  "researcherId": 1,
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

**Sauvegarder l'ID du projet :**
```bash
export PROJECT_ID=1
```

### 4.2. Lister tous les projets

```bash
curl -X GET http://localhost:8080/api/projects \
  -H "Authorization: Bearer $TOKEN"
```

### 4.3. Obtenir un projet par ID

```bash
curl -X GET http://localhost:8080/api/projects/$PROJECT_ID \
  -H "Authorization: Bearer $TOKEN"
```

### 4.4. Mettre à jour un projet

```bash
curl -X PUT http://localhost:8080/api/projects/$PROJECT_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Projet IA - Mise à jour",
    "description": "Description mise à jour"
  }'
```

### 4.5. Changer le statut d'un projet

```bash
curl -X PATCH "http://localhost:8080/api/projects/$PROJECT_ID/status?status=SUBMITTED" \
  -H "Authorization: Bearer $TOKEN"
```

### 4.6. Lister les projets d'un chercheur

```bash
curl -X GET "http://localhost:8080/api/projects/researcher/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 4.7. Supprimer un projet

```bash
curl -X DELETE http://localhost:8080/api/projects/$PROJECT_ID \
  -H "Authorization: Bearer $TOKEN"
```

## Étape 5 : Tests Validation-Service

### 5.1. Créer une validation

```bash
curl -X POST http://localhost:8080/api/validations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "projectId": 1,
    "status": "PENDING",
    "comments": "Projet en cours d'examen",
    "validationLevel": 1
  }'
```

**Note :** Utiliser un token d'un utilisateur avec le rôle VALIDATOR.

### 5.2. Lister toutes les validations

```bash
curl -X GET http://localhost:8080/api/validations \
  -H "Authorization: Bearer $TOKEN"
```

### 5.3. Obtenir les validations d'un projet

```bash
curl -X GET "http://localhost:8080/api/validations/project/$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN"
```

### 5.4. Mettre à jour une validation

```bash
curl -X PUT http://localhost:8080/api/validations/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "status": "APPROVED",
    "comments": "Projet approuvé après révision",
    "validationLevel": 2
  }'
```

## Étape 6 : Tests Finance-Service

### 6.1. Créer un budget

```bash
curl -X POST http://localhost:8080/api/finance/budgets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "projectId": 1,
    "allocatedAmount": 50000.00,
    "currency": "EUR",
    "fiscalYear": 2024
  }'
```

**Réponse attendue :**
```json
{
  "id": 1,
  "projectId": 1,
  "allocatedAmount": 50000.00,
  "spentAmount": 0.00,
  "remainingAmount": 50000.00,
  "currency": "EUR",
  "fiscalYear": 2024,
  "createdAt": "2024-01-15T10:35:00",
  "updatedAt": "2024-01-15T10:35:00"
}
```

**Sauvegarder l'ID du budget :**
```bash
export BUDGET_ID=1
```

### 6.2. Lister tous les budgets

```bash
curl -X GET http://localhost:8080/api/finance/budgets \
  -H "Authorization: Bearer $TOKEN"
```

### 6.3. Obtenir les budgets d'un projet

```bash
curl -X GET "http://localhost:8080/api/finance/budgets/project/$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN"
```

### 6.4. Créer une dépense

```bash
curl -X POST http://localhost:8080/api/finance/expenses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "projectId": 1,
    "budgetId": 1,
    "amount": 5000.00,
    "description": "Achat d'équipement de laboratoire",
    "category": "EQUIPMENT",
    "currency": "EUR"
  }'
```

### 6.5. Lister les dépenses d'un projet

```bash
curl -X GET "http://localhost:8080/api/finance/expenses/project/$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN"
```

### 6.6. Vérifier le budget mis à jour

```bash
curl -X GET "http://localhost:8080/api/finance/budgets/$BUDGET_ID" \
  -H "Authorization: Bearer $TOKEN"
```

Le `spentAmount` devrait être mis à jour automatiquement.

## Étape 7 : Tests d'Intégration Complets

### Scénario complet : Cycle de vie d'un projet R&D

```bash
# 1. Créer un utilisateur chercheur
RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "researcher2",
    "email": "researcher2@example.com",
    "password": "password123"
  }')
TOKEN=$(echo $RESPONSE | jq -r '.accessToken')
USER_ID=$(echo $RESPONSE | jq -r '.userId')

# 2. Créer un projet
PROJECT_RESPONSE=$(curl -s -X POST http://localhost:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Projet Blockchain",
    "description": "Recherche sur les applications blockchain"
  }')
PROJECT_ID=$(echo $PROJECT_RESPONSE | jq -r '.id')

# 3. Soumettre le projet
curl -X PATCH "http://localhost:8080/api/projects/$PROJECT_ID/status?status=SUBMITTED" \
  -H "Authorization: Bearer $TOKEN"

# 4. Créer un budget
BUDGET_RESPONSE=$(curl -s -X POST http://localhost:8080/api/finance/budgets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"projectId\": $PROJECT_ID,
    \"allocatedAmount\": 75000.00,
    \"currency\": \"EUR\",
    \"fiscalYear\": 2024
  }")
BUDGET_ID=$(echo $BUDGET_RESPONSE | jq -r '.id')

# 5. Enregistrer une dépense
curl -X POST http://localhost:8080/api/finance/expenses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"projectId\": $PROJECT_ID,
    \"budgetId\": $BUDGET_ID,
    \"amount\": 10000.00,
    \"description\": \"Équipement de recherche\",
    \"category\": \"EQUIPMENT\"
  }"

# 6. Vérifier le budget mis à jour
curl -X GET "http://localhost:8080/api/finance/budgets/$BUDGET_ID" \
  -H "Authorization: Bearer $TOKEN"

echo "Scénario complet terminé avec succès !"
```

## Étape 8 : Tests d'Erreurs

### Test 1 : Accès non autorisé (sans token)

```bash
curl -X GET http://localhost:8080/api/projects
```

**Réponse attendue :** 401 Unauthorized

### Test 2 : Token invalide

```bash
curl -X GET http://localhost:8080/api/projects \
  -H "Authorization: Bearer invalid-token"
```

**Réponse attendue :** 401 Unauthorized

### Test 3 : Ressource non trouvée

```bash
curl -X GET http://localhost:8080/api/projects/99999 \
  -H "Authorization: Bearer $TOKEN"
```

**Réponse attendue :** 404 Not Found

### Test 4 : Validation des données (champs manquants)

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test"
  }'
```

**Réponse attendue :** 400 Bad Request

## Script de Test Automatisé

Créer un fichier `test-all.sh` :

```bash
#!/bin/bash

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=== Tests des Microservices R&D ==="

# Test 1: Health Check
echo -n "Test Health Check... "
if curl -s "$BASE_URL/actuator/health" | grep -q "UP"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    exit 1
fi

# Test 2: Register
echo -n "Test Register... "
RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}')
if echo "$RESPONSE" | grep -q "accessToken"; then
    TOKEN=$(echo "$RESPONSE" | jq -r '.accessToken')
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    exit 1
fi

# Test 3: Create Project
echo -n "Test Create Project... "
PROJECT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/projects" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title":"Test Project","description":"Test Description"}')
if echo "$PROJECT_RESPONSE" | grep -q "id"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    exit 1
fi

echo -e "${GREEN}=== Tous les tests sont passés ===${NC}"
```

Rendre exécutable et lancer :
```bash
chmod +x test-all.sh
./test-all.sh
```

## Vérification des Logs

### Docker Compose

```bash
# Logs de tous les services
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f gateway-service
docker-compose logs -f auth-service
```

### Kubernetes

```bash
# Logs d'un pod
kubectl logs -f deployment/gateway-service -n rd-microservices
```

## Tests de Performance (Optionnel)

### Avec Apache Bench (ab)

```bash
# Test de charge sur l'endpoint de santé
ab -n 1000 -c 10 http://localhost:8080/actuator/health

# Test de charge sur l'endpoint de login
ab -n 100 -c 5 -p login.json -T application/json \
  http://localhost:8080/api/auth/login
```

## Résolution de Problèmes

### Problème : Service non accessible

1. Vérifier que le service est démarré : `docker-compose ps`
2. Vérifier les logs : `docker-compose logs [service-name]`
3. Vérifier les ports : `netstat -an | grep 8080`

### Problème : Erreur de connexion à la base de données

1. Vérifier que PostgreSQL est démarré
2. Vérifier les variables d'environnement
3. Tester la connexion manuellement : `psql -U auth_user -d auth_db`

### Problème : Token JWT invalide

1. Vérifier que le même `JWT_SECRET` est utilisé dans Gateway et Auth-Service
2. Vérifier que le token n'est pas expiré
3. Vérifier le format du header : `Authorization: Bearer <token>`

