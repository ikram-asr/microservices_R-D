# Prochaines Étapes - Après Création des Bases de Données

## ✅ Étape 1 : Vérifier les Bases de Données

### Dans pgAdmin, vérifiez que tout est créé :

```sql
-- Pour chaque base de données, exécutez :

-- auth_db
SELECT COUNT(*) as users_count FROM users;

-- project_db
SELECT COUNT(*) as projects_count FROM projects;
SELECT COUNT(*) as phases_count FROM phases;
SELECT COUNT(*) as milestones_count FROM milestones;

-- validation_db
SELECT COUNT(*) as validations_count FROM validations;
SELECT COUNT(*) as validation_steps_count FROM validation_steps;
SELECT COUNT(*) as attachments_count FROM attachments;

-- finance_db
SELECT COUNT(*) as teams_count FROM teams;
SELECT COUNT(*) as budgets_count FROM budgets;
SELECT COUNT(*) as expenses_count FROM expenses;
```

## 🚀 Étape 2 : Démarrer les Services

### Option A : Avec Docker Compose (Recommandé pour développement)

```bash
# 1. Build les images Docker
docker-compose build

# 2. Démarrer tous les services
docker-compose up -d

# 3. Vérifier que tous les services sont en cours d'exécution
docker-compose ps

# 4. Voir les logs
docker-compose logs -f
```

### Option B : Avec Maven (Développement local)

```bash
# 1. Build tous les services
mvn clean install

# 2. Démarrer chaque service dans un terminal séparé :

# Terminal 1 - Gateway
cd gateway-service
mvn spring-boot:run

# Terminal 2 - Auth Service
cd auth-service
mvn spring-boot:run

# Terminal 3 - Project Service
cd project-service
mvn spring-boot:run

# Terminal 4 - Validation Service
cd validation-service
mvn spring-boot:run

# Terminal 5 - Finance Service
cd finance-service
mvn spring-boot:run
```

### Option C : Avec Kubernetes

```bash
# 1. Créer le namespace
kubectl create namespace rd-microservices

# 2. Créer les secrets
kubectl apply -f k8s/secrets.yaml -n rd-microservices

# 3. Créer les ConfigMaps
kubectl apply -f k8s/configmaps.yaml -n rd-microservices

# 4. Déployer les bases de données
kubectl apply -f k8s/postgres/ -n rd-microservices

# 5. Attendre que les bases soient prêtes
kubectl wait --for=condition=ready pod -l app=postgres-auth -n rd-microservices --timeout=300s

# 6. Déployer les microservices
kubectl apply -f k8s/services/ -n rd-microservices

# 7. Vérifier le déploiement
kubectl get pods -n rd-microservices
```

## 🔍 Étape 3 : Vérifier que les Services Démarrés

### Health Checks

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

**Réponse attendue :** `{"status":"UP"}`

## 🧪 Étape 4 : Tester les API

### 4.1. Test d'Authentification

```bash
# Inscription d'un nouvel utilisateur
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'

# Connexion (utilisez un utilisateur existant de vos données de test)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "researcher1",
    "password": "password123"
  }'

# Sauvegarder le token reçu
export TOKEN="votre-token-jwt-ici"
```

### 4.2. Test Project Service

```bash
# Créer un projet
curl -X POST http://localhost:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "nom": "Mon Nouveau Projet",
    "description": "Description du projet"
  }'

# Lister tous les projets
curl -X GET http://localhost:8080/api/projects \
  -H "Authorization: Bearer $TOKEN"

# Obtenir un projet par ID
curl -X GET http://localhost:8080/api/projects/1 \
  -H "Authorization: Bearer $TOKEN"
```

### 4.3. Test Validation Service

```bash
# Créer une validation
curl -X POST http://localhost:8080/api/validations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "idProject": 1,
    "nomTest": "Test de Performance",
    "statut": "PENDING"
  }'

# Lister les validations d'un projet
curl -X GET http://localhost:8080/api/validations/project/1 \
  -H "Authorization: Bearer $TOKEN"
```

### 4.4. Test Finance Service

```bash
# Créer une équipe
curl -X POST http://localhost:8080/api/finance/teams \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "nom": "Équipe Développement"
  }'

# Créer un budget
curl -X POST http://localhost:8080/api/finance/budgets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "idProject": 1,
    "montant": 50000.00
  }'

# Créer une dépense
curl -X POST http://localhost:8080/api/finance/expenses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "idProject": 1,
    "idTeam": 1,
    "montant": 5000.00
  }'
```

## 📊 Étape 5 : Vérifier les Logs

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
# Logs d'un service
kubectl logs -f deployment/gateway-service -n rd-microservices
```

## 🔧 Étape 6 : Résoudre les Problèmes Courants

### Problème : Service ne démarre pas

**Vérifications :**
1. Port déjà utilisé ? `netstat -an | grep 8080`
2. Base de données accessible ? Vérifiez les variables d'environnement
3. Logs d'erreur ? Regardez les logs du service

### Problème : Erreur de connexion à la base de données

**Solutions :**
1. Vérifiez que PostgreSQL est démarré
2. Vérifiez les credentials dans `application.yml`
3. Testez la connexion manuellement :
   ```bash
   psql -U auth_user -d auth_db -h localhost
   ```

### Problème : Token JWT invalide

**Solutions :**
1. Vérifiez que le même `JWT_SECRET` est utilisé dans Gateway et Auth-Service
2. Vérifiez que le token n'est pas expiré
3. Format du header : `Authorization: Bearer <token>`

### Problème : Erreur 404 sur les endpoints

**Solutions :**
1. Vérifiez que le Gateway route correctement
2. Vérifiez que les services sont démarrés
3. Vérifiez les routes dans `gateway-service/src/main/resources/application.yml`

## 📝 Étape 7 : Tests d'Intégration Complets

### Scénario complet : Cycle de vie d'un projet

```bash
# 1. Créer un utilisateur
RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"researcher3","email":"researcher3@example.com","password":"password123"}')
TOKEN=$(echo $RESPONSE | jq -r '.accessToken')

# 2. Créer un projet
PROJECT=$(curl -s -X POST http://localhost:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"nom":"Projet Test","description":"Description"}')
PROJECT_ID=$(echo $PROJECT | jq -r '.idProject')

# 3. Créer un budget
BUDGET=$(curl -s -X POST http://localhost:8080/api/finance/budgets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"idProject\":$PROJECT_ID,\"montant\":100000.00}")

# 4. Créer une validation
VALIDATION=$(curl -s -X POST http://localhost:8080/api/validations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"idProject\":$PROJECT_ID,\"nomTest\":\"Test Intégration\",\"statut\":\"PENDING\"}")

echo "Scénario complet terminé avec succès !"
```

## 🎯 Étape 8 : Prochaines Améliorations

### À implémenter :

1. **Services pour Phase et Milestone**
   - Créer les controllers et services pour gérer les phases et milestones

2. **Services pour ValidationStep et Attachment**
   - Créer les endpoints pour gérer les étapes de validation et les pièces jointes

3. **Amélioration de la sécurité**
   - Rate limiting
   - HTTPS
   - Validation des rôles au niveau du Gateway

4. **Monitoring**
   - Configurer Prometheus
   - Créer des dashboards Grafana
   - Configurer ELK pour les logs

5. **Tests**
   - Tests unitaires
   - Tests d'intégration
   - Tests de charge

6. **Documentation API**
   - Swagger/OpenAPI pour chaque service
   - Documentation des endpoints

## 📚 Ressources Utiles

- **Architecture** : Voir `ARCHITECTURE.md`
- **MCD** : Voir `MCD.md`
- **Tests** : Voir `TESTING.md`
- **Déploiement** : Voir `DEPLOYMENT.md`

## ✅ Checklist de Vérification

- [ ] Bases de données créées et vérifiées
- [ ] Données de test insérées
- [ ] Tous les services démarrés
- [ ] Health checks OK
- [ ] Authentification fonctionnelle
- [ ] CRUD projets fonctionnel
- [ ] CRUD validations fonctionnel
- [ ] CRUD budgets/dépenses fonctionnel
- [ ] Logs sans erreurs critiques
- [ ] Tests d'intégration passés

Une fois tous ces points vérifiés, votre application microservices est prête pour le développement et les tests ! 🎉

