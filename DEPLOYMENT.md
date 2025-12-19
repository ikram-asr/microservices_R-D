# Guide de Déploiement

## Prérequis

- Docker et Docker Compose installés
- Kubernetes cluster (minikube, kind, ou cloud)
- kubectl configuré
- Maven 3.8+ (pour build local)

## Option 1 : Déploiement avec Docker Compose (Développement)

### Étape 1 : Build des images Docker

```bash
# Build toutes les images
docker-compose build

# Ou build un service spécifique
docker-compose build auth-service
```

### Étape 2 : Démarrer les services

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down
```

### Étape 3 : Vérifier le déploiement

```bash
# Vérifier que tous les services sont en cours d'exécution
docker-compose ps

# Tester le Gateway
curl http://localhost:8080/actuator/health

# Tester l'Auth Service
curl http://localhost:8081/actuator/health
```

## Option 2 : Déploiement avec Kubernetes

### Étape 1 : Créer le namespace

```bash
kubectl create namespace rd-microservices
```

### Étape 2 : Build et push des images Docker

Vous devez d'abord build les images et les pousser vers un registry Docker :

```bash
# Build les images
docker build -t your-registry/gateway-service:latest ./gateway-service
docker build -t your-registry/auth-service:latest ./auth-service
docker build -t your-registry/project-service:latest ./project-service
docker build -t your-registry/validation-service:latest ./validation-service
docker build -t your-registry/finance-service:latest ./finance-service

# Push vers le registry
docker push your-registry/gateway-service:latest
docker push your-registry/auth-service:latest
docker push your-registry/project-service:latest
docker push your-registry/validation-service:latest
docker push your-registry/finance-service:latest
```

**Note** : Mettez à jour les fichiers YAML dans `k8s/services/` avec votre registry.

### Étape 3 : Déployer les secrets

```bash
kubectl apply -f k8s/secrets.yaml
```

**Important** : Modifiez les secrets dans `k8s/secrets.yaml` avant le déploiement en production !

### Étape 4 : Déployer les ConfigMaps

```bash
kubectl apply -f k8s/configmaps.yaml
```

### Étape 5 : Déployer les bases de données PostgreSQL

```bash
kubectl apply -f k8s/postgres/
```

Attendre que les bases soient prêtes :

```bash
kubectl wait --for=condition=ready pod -l app=postgres-auth -n rd-microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=postgres-project -n rd-microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=postgres-validation -n rd-microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=postgres-finance -n rd-microservices --timeout=300s
```

### Étape 6 : Déployer les microservices

```bash
kubectl apply -f k8s/services/
```

### Étape 7 : Vérifier le déploiement

```bash
# Voir tous les pods
kubectl get pods -n rd-microservices

# Voir les services
kubectl get svc -n rd-microservices

# Voir les logs d'un service
kubectl logs -f deployment/gateway-service -n rd-microservices

# Port-forward pour accéder au Gateway
kubectl port-forward svc/gateway-service 8080:8080 -n rd-microservices
```

## Tests

### Test d'inscription

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "researcher1",
    "email": "researcher1@example.com",
    "password": "password123"
  }'
```

### Test de connexion

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "researcher1",
    "password": "password123"
  }'
```

### Test avec JWT

```bash
# Récupérer le token depuis la réponse de login
TOKEN="your-jwt-token-here"

# Créer un projet
curl -X POST http://localhost:8080/api/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Mon Projet R&D",
    "description": "Description du projet"
  }'
```

## Dépannage

### Vérifier les logs

```bash
# Docker Compose
docker-compose logs -f [service-name]

# Kubernetes
kubectl logs -f [pod-name] -n rd-microservices
```

### Vérifier la santé des services

```bash
# Docker Compose
curl http://localhost:8080/actuator/health

# Kubernetes
kubectl get pods -n rd-microservices
kubectl describe pod [pod-name] -n rd-microservices
```

### Problèmes de connexion à la base de données

1. Vérifier que PostgreSQL est démarré
2. Vérifier les credentials dans les variables d'environnement
3. Vérifier la connectivité réseau (Docker network ou K8s service)

### Problèmes JWT

1. Vérifier que le même `JWT_SECRET` est utilisé dans Gateway et Auth-Service
2. Vérifier que le token n'est pas expiré
3. Vérifier le format du header Authorization: `Bearer <token>`

## Scaling

### Docker Compose

Modifier le nombre de répliques dans `docker-compose.yml` (non supporté nativement, utiliser docker swarm).

### Kubernetes

```bash
# Scale un service
kubectl scale deployment gateway-service --replicas=3 -n rd-microservices

# Ou modifier directement le fichier YAML
kubectl edit deployment gateway-service -n rd-microservices
```

## Mise à jour

### Docker Compose

```bash
# Rebuild et redémarrer
docker-compose up -d --build [service-name]
```

### Kubernetes

```bash
# Mettre à jour l'image
kubectl set image deployment/gateway-service gateway-service=your-registry/gateway-service:v2.0 -n rd-microservices

# Ou appliquer les nouveaux manifests
kubectl apply -f k8s/services/
```

