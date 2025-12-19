# Microservices R&D - Application de Recherche et Développement

Architecture microservices complète avec Spring Boot, Kubernetes, et PostgreSQL.

## 🏗️ Architecture

Voir [ARCHITECTURE.md](./ARCHITECTURE.md) pour les détails complets.

## 📋 Prérequis

- Java 17+
- Maven 3.8+
- Docker & Docker Compose
- Kubernetes (minikube, kind, ou cluster K8s)
- kubectl configuré
- PostgreSQL 14+ (ou via Docker)

## 🚀 Démarrage Rapide

### Option 1 : Docker Compose (Développement)

```bash
# Démarrer toutes les bases de données
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance

# Attendre que les bases soient prêtes (30 secondes)
sleep 30

# Build et démarrer tous les services
docker-compose up --build
```

### Option 2 : Kubernetes (Production)

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

# 6. Exécuter les migrations (via init containers ou jobs)
kubectl apply -f k8s/migrations/ -n rd-microservices

# 7. Déployer les microservices
kubectl apply -f k8s/services/ -n rd-microservices

# 8. Vérifier le déploiement
kubectl get pods -n rd-microservices
```

## 🔧 Configuration

### Variables d'environnement

Chaque service nécessite :
- `SPRING_DATASOURCE_URL` : URL de la base de données
- `SPRING_DATASOURCE_USERNAME` : Utilisateur PostgreSQL
- `SPRING_DATASOURCE_PASSWORD` : Mot de passe PostgreSQL
- `JWT_SECRET` : Secret pour signer les tokens JWT (partagé entre Gateway et Auth)

### Ports par défaut

- Gateway: `8080`
- Auth-Service: `8081`
- Project-Service: `8082`
- Validation-Service: `8083`
- Finance-Service: `8084`

## 📡 API Endpoints

### Gateway (http://localhost:8080)

- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `GET /api/projects` - Liste des projets (authentifié)
- `GET /api/projects/{id}` - Détails projet
- `POST /api/projects` - Créer projet
- `GET /api/validations` - Liste validations
- `GET /api/finance/budgets` - Budgets

### Auth-Service (http://localhost:8081)

- `POST /auth/register` - Inscription
- `POST /auth/login` - Connexion
- `POST /auth/validate` - Valider token JWT
- `GET /auth/users` - Liste utilisateurs (ADMIN)

## 🧪 Tests

```bash
# Tests unitaires
mvn test

# Tests d'intégration
mvn verify
```

## 📊 Monitoring

### Prometheus
- Métriques disponibles sur `/actuator/prometheus` de chaque service

### Grafana
- Dashboards disponibles dans `monitoring/grafana/`

### Logs ELK
- Configuration dans `monitoring/elk/`

## 🔐 Sécurité

- JWT avec expiration (1h pour access token, 7j pour refresh token)
- Secrets stockés dans Kubernetes Secrets
- HTTPS recommandé en production

## 📝 Structure du Projet

```
.
├── gateway-service/          # API Gateway
├── auth-service/             # Service d'authentification
├── project-service/          # Gestion des projets
├── validation-service/       # Workflow de validation
├── finance-service/          # Gestion financière
├── k8s/                      # Manifests Kubernetes
│   ├── services/            # Deployments et Services
│   ├── postgres/            # Bases de données
│   ├── configmaps.yaml      # Configurations
│   └── secrets.yaml         # Secrets
├── docker-compose.yml        # Développement local
└── README.md
```

## 🛠️ Développement

### Build local

```bash
# Build tous les services
mvn clean install

# Build un service spécifique
cd gateway-service && mvn clean install
```

### Run local (sans Docker)

1. Démarrer PostgreSQL manuellement
2. Configurer les variables d'environnement
3. Lancer chaque service :
```bash
cd gateway-service && mvn spring-boot:run
cd auth-service && mvn spring-boot:run
# etc.
```

## 📚 Documentation API

- Swagger UI disponible sur chaque service : `http://localhost:PORT/swagger-ui.html`
- Documentation OpenAPI : `http://localhost:PORT/v3/api-docs`

## 🤝 Contribution

1. Créer une branche feature
2. Développer et tester
3. Créer une Pull Request

## 📄 Licence

Propriétaire - Usage interne R&D

