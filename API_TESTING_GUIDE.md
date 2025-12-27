# 🧪 Guide Complet de Test des APIs

## 📋 Vue d'Ensemble

Vous avez **2 façons** de tester les APIs :

1. **Via NGINX Gateway** (Port 8080) - Recommandé pour la production
2. **Directement sur les services** (Ports 8081-8084) - Pour le développement

---

## 🚀 Étape 0 : Vérifier que les Services sont Démarrés

```bash
# Vérifier les conteneurs
docker-compose ps

# Vérifier les health checks
curl http://localhost:8080/health  # NGINX
curl http://localhost:8081/actuator/health  # Auth Service
curl http://localhost:8082/actuator/health  # Project Service
curl http://localhost:8083/actuator/health  # Validation Service
curl http://localhost:8084/actuator/health  # Finance Service
```

---

## 🔐 ÉTAPE 1 : Authentification

### Option A : Via NGINX Gateway (Port 8080)

#### 1.1 Inscription (Register)

**Windows PowerShell :**
```powershell
$body = @{
    username = "newuser"
    email = "newuser@example.com"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

**Linux/Mac (curl) :**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "password123"
  }'
```

**Réponse attendue :**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "newuser",
  "email": "newuser@example.com",
  "role": "RESEARCHER"
}
```

#### 1.2 Connexion (Login)

**Windows PowerShell :**
```powershell
$body = @{
    username = "newuser"
    password = "password123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body

# Sauvegarder le token
$token = $response.token
Write-Host "Token: $token"
```

**Linux/Mac (curl) :**
```bash
# Login et sauvegarder le token
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "password": "password123"
  }' | jq -r '.token')

echo "Token: $TOKEN"
```

**Réponse attendue :**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "newuser",
  "email": "newuser@example.com",
  "role": "RESEARCHER"
}
```

### Option B : Directement sur Auth-Service (Port 8081)

**⚠️ IMPORTANT :** Utilisez `/auth/register` (pas `/api/auth/register`) car vous appelez directement le service.

**Windows PowerShell :**
```powershell
$body = @{
    username = "newuser"
    email = "newuser@example.com"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8081/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

**Linux/Mac (curl) :**
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "password123"
  }'
```

---

## 📁 ÉTAPE 2 : Projets (Project Service)

### 2.1 Créer un Projet

**Via NGINX (avec authentification) :**

**Windows PowerShell :**
```powershell
$body = @{
    nom = "Projet R&D Test"
    description = "Description du projet de test"
    statut = "DRAFT"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/projects" `
    -Method Post `
    -ContentType "application/json" `
    -Headers @{Authorization = "Bearer $token"} `
    -Body $body
```

**Linux/Mac (curl) :**
```bash
curl -X POST http://localhost:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "nom": "Projet R&D Test",
    "description": "Description du projet de test",
    "statut": "DRAFT"
  }'
```

**Directement sur Project-Service (sans authentification pour le dev) :**

```bash
curl -X POST http://localhost:8082/projects \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Projet R&D Test",
    "description": "Description du projet de test",
    "statut": "DRAFT"
  }'
```

### 2.2 Lister tous les Projets

**Via NGINX :**
```bash
curl -X GET http://localhost:8080/api/projects \
  -H "Authorization: Bearer $TOKEN"
```

**Directement :**
```bash
curl -X GET http://localhost:8082/projects
```

### 2.3 Obtenir un Projet par ID

**Via NGINX :**
```bash
curl -X GET http://localhost:8080/api/projects/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Directement :**
```bash
curl -X GET http://localhost:8082/projects/1
```

### 2.4 Mettre à jour un Projet

**Via NGINX :**
```bash
curl -X PUT http://localhost:8080/api/projects/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "nom": "Projet R&D Mis à jour",
    "description": "Nouvelle description",
    "statut": "SUBMITTED"
  }'
```

### 2.5 Supprimer un Projet

**Via NGINX :**
```bash
curl -X DELETE http://localhost:8080/api/projects/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## ✅ ÉTAPE 3 : Validations (Validation Service)

### 3.1 Créer une Validation

**Via NGINX :**
```bash
curl -X POST http://localhost:8080/api/validations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "idProject": 1,
    "nomTest": "Test de validation",
    "statut": "PENDING"
  }'
```

**Directement :**
```bash
curl -X POST http://localhost:8083/validations \
  -H "Content-Type: application/json" \
  -d '{
    "idProject": 1,
    "nomTest": "Test de validation",
    "statut": "PENDING"
  }'
```

### 3.2 Lister les Validations

**Via NGINX :**
```bash
curl -X GET http://localhost:8080/api/validations \
  -H "Authorization: Bearer $TOKEN"
```

### 3.3 Obtenir les Validations d'un Projet

**Via NGINX :**
```bash
curl -X GET http://localhost:8080/api/validations/project/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## 💰 ÉTAPE 4 : Finance (Finance Service)

### 4.1 Créer un Budget

**Via NGINX :**
```bash
curl -X POST http://localhost:8080/api/finance/budgets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "idProject": 1,
    "montant": 50000.00
  }'
```

**Directement :**
```bash
curl -X POST http://localhost:8084/finance/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "idProject": 1,
    "montant": 50000.00
  }'
```

### 4.2 Créer une Dépense

**Via NGINX :**
```bash
curl -X POST http://localhost:8080/api/finance/expenses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "idProject": 1,
    "idTeam": 1,
    "montant": 1000.00,
    "description": "Achat matériel"
  }'
```

### 4.3 Lister les Budgets

**Via NGINX :**
```bash
curl -X GET http://localhost:8080/api/finance/budgets \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📝 Utilisation avec Postman/Insomnia

### Configuration Postman

1. **Créer une Collection** : "R&D Microservices"

2. **Variables d'environnement** :
   - `base_url` : `http://localhost:8080` (ou `http://localhost:8081` pour direct)
   - `token` : (sera rempli après login)

3. **Requête Register** :
   - Method : `POST`
   - URL : `{{base_url}}/api/auth/register`
   - Headers : `Content-Type: application/json`
   - Body (raw JSON) :
     ```json
     {
       "username": "newuser",
       "email": "newuser@example.com",
       "password": "password123"
     }
     ```

4. **Requête Login** :
   - Method : `POST`
   - URL : `{{base_url}}/api/auth/login`
   - Headers : `Content-Type: application/json`
   - Body (raw JSON) :
     ```json
     {
       "username": "newuser",
       "password": "password123"
     }
     ```
   - **Tests Script** (pour sauvegarder le token automatiquement) :
     ```javascript
     if (pm.response.code === 200) {
         var jsonData = pm.response.json();
         pm.environment.set("token", jsonData.token);
     }
     ```

5. **Requêtes Protégées** :
   - Headers : 
     - `Content-Type: application/json`
     - `Authorization: Bearer {{token}}`

### Configuration Insomnia

Similaire à Postman, mais avec une interface différente.

---

## 🔍 Tests de Validation du Token

### Valider un Token

**Via NGINX :**
```bash
curl -X POST http://localhost:8080/api/auth/validate \
  -H "Authorization: Bearer $TOKEN"
```

**Directement :**
```bash
curl -X POST http://localhost:8081/auth/validate \
  -H "Authorization: Bearer $TOKEN"
```

**Réponse attendue :**
```json
true
```

---

## 📊 Endpoints de Monitoring

### Health Checks

```bash
# Via NGINX
curl http://localhost:8080/health

# Services individuels
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health
curl http://localhost:8084/actuator/health
```

### Métriques Prometheus

```bash
curl http://localhost:8081/actuator/prometheus
curl http://localhost:8082/actuator/prometheus
curl http://localhost:8083/actuator/prometheus
curl http://localhost:8084/actuator/prometheus
```

---

## ❌ Erreurs Courantes et Solutions

### 1. Erreur 403 Forbidden

**Cause :** Endpoint protégé sans token ou token invalide

**Solution :**
```bash
# Vérifier que vous avez un token valide
echo $TOKEN  # Linux/Mac
echo $token  # PowerShell

# Refaire un login si nécessaire
```

### 2. Erreur 401 Unauthorized

**Cause :** Token expiré ou invalide

**Solution :**
```bash
# Refaire un login pour obtenir un nouveau token
```

### 3. Erreur 404 Not Found

**Cause :** URL incorrecte

**Solution :**
- Via NGINX : Utiliser `/api/auth/register` (avec `/api`)
- Directement : Utiliser `/auth/register` (sans `/api`)

### 4. Erreur 500 Internal Server Error

**Cause :** Problème avec la base de données ou le service

**Solution :**
```bash
# Vérifier les logs
docker-compose logs auth-service
docker-compose logs project-service

# Vérifier que les bases de données sont démarrées
docker-compose ps | grep postgres
```

### 5. Erreur de Connexion (Connection refused)

**Cause :** Service non démarré

**Solution :**
```bash
# Vérifier les conteneurs
docker-compose ps

# Redémarrer si nécessaire
docker-compose restart auth-service
```

---

## 📋 Checklist de Test Complète

### Authentification
- [ ] Inscription réussie (201 Created)
- [ ] Login réussie (200 OK avec token)
- [ ] Validation du token (200 OK avec true)
- [ ] Login avec mauvais mot de passe (401 Unauthorized)

### Projets
- [ ] Créer un projet (201 Created)
- [ ] Lister les projets (200 OK)
- [ ] Obtenir un projet par ID (200 OK)
- [ ] Mettre à jour un projet (200 OK)
- [ ] Supprimer un projet (200 OK)
- [ ] Accès sans token (401/403)

### Validations
- [ ] Créer une validation (201 Created)
- [ ] Lister les validations (200 OK)
- [ ] Obtenir les validations d'un projet (200 OK)

### Finance
- [ ] Créer un budget (201 Created)
- [ ] Créer une dépense (201 Created)
- [ ] Lister les budgets (200 OK)
- [ ] Lister les dépenses (200 OK)

---

## 🚀 Script de Test Automatique

J'ai créé des scripts de test dans `scripts/test-api.sh` et `scripts/test-api.ps1`.

**Windows PowerShell :**
```powershell
.\scripts\test-api.ps1
```

**Linux/Mac :**
```bash
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

---

## 📚 Résumé des URLs

### Via NGINX Gateway (Port 8085) ✅
- Auth : `http://localhost:8085/api/auth/*`
- Projects : `http://localhost:8085/api/projects/*`
- Validations : `http://localhost:8085/api/validations/*`
- Finance : `http://localhost:8085/api/finance/*`

### Directement sur les Services
- Auth : `http://localhost:8081/auth/*`
- Projects : `http://localhost:8082/projects/*`
- Validations : `http://localhost:8083/validations/*`
- Finance : `http://localhost:8084/finance/*`

**⚠️ IMPORTANT :** NGINX est sur le port **8085**. Voir `PORTS_VERIFICATION.md` pour tous les détails.

---

## 💡 Conseils

1. **Toujours commencer par l'authentification** pour obtenir un token
2. **Utiliser NGINX (port 8080)** pour tester le comportement en production
3. **Utiliser les services directs** pour le développement et le débogage
4. **Sauvegarder le token** dans une variable d'environnement
5. **Vérifier les logs** si une erreur survient : `docker-compose logs <service>`

---

**Bon test ! 🎉**

