# Architecture Microservices R&D

## Vue d'ensemble

Cette application suit une architecture microservices distribuée avec les composants suivants :

```
┌─────────────────────────────────────────────────────────────┐
│                    Client (Frontend/API)                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              API Gateway (Spring Cloud Gateway)              │
│              Port: 8080                                      │
│              - Routage                                       │
│              - Authentification JWT                          │
│              - Rate Limiting                                │
└──────┬──────────────────────────────────────────────────────┘
       │
       ├──────────┬──────────┬──────────┬──────────┐
       │          │          │          │          │
       ▼          ▼          ▼          ▼          ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│  Auth    │ │ Project  │ │Validation│ │ Finance  │ │  (Future)│
│ Service  │ │ Service  │ │ Service  │ │ Service  │ │ Services │
│ :8081    │ │ :8082    │ │ :8083    │ │ :8084    │ │          │
└────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └──────────┘
     │           │            │            │
     ▼           ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│PostgreSQL│ │PostgreSQL│ │PostgreSQL│ │PostgreSQL│
│  :5432   │ │  :5432   │ │  :5432   │ │  :5432   │
│  auth_db │ │project_db│ │valid_db  │ │finance_db│
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

## Services

### 1. Gateway-Service (Port 8080)
- **Rôle** : Point d'entrée unique pour tous les clients
- **Technologies** : Spring Cloud Gateway
- **Fonctionnalités** :
  - Routage des requêtes vers les microservices
  - Validation JWT
  - Rate limiting
  - Load balancing

### 2. Auth-Service (Port 8081)
- **Rôle** : Gestion de l'authentification et autorisation
- **Technologies** : Spring Boot, JWT, PostgreSQL
- **Fonctionnalités** :
  - Inscription/Connexion utilisateurs
  - Génération et validation de tokens JWT
  - Gestion des rôles (ADMIN, RESEARCHER, VALIDATOR, FINANCE)
  - Refresh tokens

### 3. Project-Service (Port 8082)
- **Rôle** : Gestion des projets R&D
- **Technologies** : Spring Boot, PostgreSQL
- **Fonctionnalités** :
  - CRUD projets
  - Statuts (DRAFT, SUBMITTED, IN_REVIEW, APPROVED, REJECTED)
  - Association chercheurs/projets

### 4. Validation-Service (Port 8083)
- **Rôle** : Workflow de validation scientifique
- **Technologies** : Spring Boot, PostgreSQL
- **Fonctionnalités** :
  - Workflow de validation multi-niveaux
  - Commentaires et annotations
  - Historique des validations

### 5. Finance-Service (Port 8084)
- **Rôle** : Gestion budgétaire
- **Technologies** : Spring Boot, PostgreSQL
- **Fonctionnalités** :
  - Budgets par projet
  - Suivi des dépenses
  - Rapports financiers

## Communication Inter-Services

- **Synchronisation** : REST API (HTTP)
- **Asynchrone** : (Optionnel) RabbitMQ/Kafka pour événements

## Sécurité

- **JWT** : Tokens signés avec secret partagé
- **HTTPS** : Recommandé en production
- **CORS** : Configuré au niveau Gateway

## Base de données

- **Isolation** : Une base PostgreSQL par microservice
- **Migrations** : Flyway ou Liquibase
- **Backup** : Stratégie de backup par service

## Déploiement Kubernetes

- **Namespace** : `rd-microservices`
- **Services** : ClusterIP pour communication interne
- **Ingress** : Point d'entrée externe vers Gateway
- **ConfigMaps** : Configuration centralisée
- **Secrets** : Credentials et JWT secrets

## Monitoring

- **Prometheus** : Métriques des services
- **Grafana** : Dashboards de visualisation
- **ELK Stack** : Centralisation des logs

## CI/CD

- **GitHub Actions** : Pipeline de build et déploiement
- **Docker Hub/Registry** : Stockage des images
- **Helm Charts** : (Optionnel) Gestion des déploiements K8s

