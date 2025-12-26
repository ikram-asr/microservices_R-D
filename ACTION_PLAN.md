# 🎯 Plan d'Action - Prochaines Étapes

## 📋 Vue d'Ensemble

Vous avez maintenant tous les fichiers de configuration. Voici l'ordre des actions à effectuer pour mettre en place le projet.

---

## 🚀 ÉTAPE 1 : Installation des Outils de Base (30-60 min)

### 1.1 Vérifier les Prérequis

```bash
# Vérifier Java
java -version  # Doit être 17+

# Vérifier Maven
mvn -version

# Vérifier Git
git --version

# Vérifier Docker
docker --version
docker-compose --version
```

**Si manquant :** Suivre `INSTALLATION_GUIDE.md` section "Outils de Base"

### 2. Installer Kubernetes (Choisir une option)

**Option A : Minikube (Recommandé pour débutants)**
```bash
# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# macOS
brew install minikube

# Démarrer
minikube start --driver=docker
kubectl get nodes
```

**Option B : kind (Plus léger)**
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind create cluster --name rd-microservices
```

**Option C : k3d (Très léger)**
```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create rd-microservices
```

### 3. Installer kubectl

```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# macOS
brew install kubectl

# Vérifier
kubectl version --client
```

**✅ Vérification :**
```bash
kubectl get nodes  # Doit afficher votre cluster
```

---

## 🐳 ÉTAPE 2 : Test Local avec Docker Compose (15-30 min)

### 2.1 Démarrer les Services

```bash
# Créer le réseau Docker
docker network create rd-network

# Démarrer tous les services
docker-compose up -d

# Vérifier que tout est démarré
docker-compose ps
```

### 2.2 Vérifier les Services

**Attendre 1-2 minutes pour que tout démarre, puis vérifier :**

```bash
# Vérifier les logs
docker-compose logs keycloak
docker-compose logs nginx-gateway

# Vérifier les services
curl http://localhost:8080/health  # NGINX
curl http://localhost:8090/health  # Keycloak
curl http://localhost:9090/-/healthy  # Prometheus
```

### 2.3 Accéder aux Interfaces

- **NGINX Gateway** : http://localhost:8080
- **Keycloak** : http://localhost:8090 (admin / admin123)
- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin / admin123)
- **Kibana** : http://localhost:5601

**✅ Si tout fonctionne :** Passer à l'étape 3
**❌ Si erreurs :** Vérifier les logs avec `docker-compose logs <service>`

---

## 🔐 ÉTAPE 3 : Configuration Keycloak (15-20 min)

### 3.1 Accéder à Keycloak

1. Ouvrir : http://localhost:8090
2. Cliquer sur "Administration Console"
3. Login : `admin` / `admin123`

### 3.2 Importer le Realm

1. Dans le menu de gauche : **Administration** → **Import realm**
2. Cliquer sur **Select File**
3. Sélectionner : `keycloak/realm-config/rd-realm.json`
4. Cliquer sur **Import**

### 3.3 Vérifier la Configuration

1. Vérifier que le realm **"rd-microservices"** est créé
2. Vérifier le client **"rd-gateway"** :
   - Clients → rd-gateway
   - Vérifier le secret (à changer en production)
3. Vérifier les utilisateurs :
   - Users → Voir admin et researcher1

### 3.4 Tester l'Authentification

```bash
# Obtenir un token
curl -X POST http://localhost:8090/realms/rd-microservices/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=rd-gateway" \
  -d "client_secret=rd-gateway-secret-change-in-production" \
  -d "grant_type=client_credentials"
```

**✅ Si vous obtenez un token :** Keycloak est configuré correctement

---

## ☸️ ÉTAPE 4 : Préparation Kubernetes (10-15 min)

### 4.1 Créer le Namespace

```bash
kubectl create namespace rd-microservices
```

### 4.2 Créer les Secrets

**⚠️ IMPORTANT :** Changer les mots de passe avant de déployer en production !

```bash
# Créer les secrets
kubectl create secret generic keycloak-secret \
  --from-literal=admin-password='admin123' \
  --from-literal=db-password='keycloak_password' \
  -n rd-microservices

kubectl create secret generic grafana-secret \
  --from-literal=admin-password='admin123' \
  -n rd-microservices

# Ou utiliser le fichier (modifier les mots de passe d'abord)
kubectl apply -f k8s/secrets.yaml -n rd-microservices
```

### 4.3 Vérifier

```bash
kubectl get secrets -n rd-microservices
```

---

## 🚀 ÉTAPE 5 : Déploiement sur Kubernetes (20-30 min)

### 5.1 Déployer Keycloak

```bash
kubectl apply -f keycloak/k8s/keycloak.yaml -n rd-microservices

# Attendre que Keycloak soit prêt
kubectl wait --for=condition=ready pod -l app=keycloak -n rd-microservices --timeout=300s
```

### 5.2 Déployer les Bases de Données

```bash
kubectl apply -f k8s/postgres/ -n rd-microservices

# Vérifier
kubectl get pods -n rd-microservices | grep postgres
```

### 5.3 Déployer les Services Applicatifs

```bash
kubectl apply -f k8s/services/ -n rd-microservices

# Vérifier
kubectl get pods -n rd-microservices
```

### 5.4 Build et Déployer NGINX

**Option A : Utiliser une image existante**
```bash
# Modifier nginx/k8s/nginx-gateway.yaml pour pointer vers votre registry
# Puis :
kubectl apply -f nginx/k8s/nginx-gateway.yaml -n rd-microservices
```

**Option B : Build local et push**
```bash
# Build l'image
cd nginx
docker build -t nginx-gateway:latest .

# Si vous utilisez Minikube
eval $(minikube docker-env)
docker build -t nginx-gateway:latest .

# Déployer
kubectl apply -f k8s/nginx-gateway.yaml -n rd-microservices
```

### 5.5 Déployer le Monitoring

```bash
# Prometheus
kubectl apply -f monitoring/prometheus/k8s/prometheus.yaml -n rd-microservices

# Grafana
kubectl apply -f monitoring/grafana/k8s/grafana.yaml -n rd-microservices

# ELK Stack
kubectl apply -f monitoring/elk/k8s/ -n rd-microservices
```

### 5.6 Vérifier le Déploiement

```bash
# Voir tous les pods
kubectl get pods -n rd-microservices

# Voir les services
kubectl get services -n rd-microservices

# Voir les logs d'un service
kubectl logs -f deployment/keycloak -n rd-microservices
```

**✅ Si tous les pods sont "Running" :** Passer à l'étape 6

---

## 📊 ÉTAPE 6 : Configuration Grafana (10-15 min)

### 6.1 Accéder à Grafana

**Si en local (Docker Compose) :**
- http://localhost:3000

**Si sur Kubernetes :**
```bash
# Port-forward
kubectl port-forward svc/grafana 3000:3000 -n rd-microservices
```
- http://localhost:3000

### 6.2 Premier Login

- Username : `admin`
- Password : `admin123` (changer au premier login)

### 6.3 Ajouter Prometheus comme Datasource

1. Configuration → Data sources → Add data source
2. Sélectionner **Prometheus**
3. URL :
   - Docker Compose : `http://prometheus:9090`
   - Kubernetes : `http://prometheus:9090`
4. Cliquer sur **Save & Test**

### 6.4 Importer le Dashboard

1. Dashboards → Import
2. Upload `monitoring/grafana/dashboards/microservices-dashboard.json`
3. Sélectionner Prometheus comme datasource
4. Cliquer sur **Import**

**✅ Si le dashboard s'affiche :** Grafana est configuré

---

## 📝 ÉTAPE 7 : Configuration ELK Stack (15-20 min)

### 7.1 Attendre qu'Elasticsearch soit Prêt

```bash
kubectl wait --for=condition=ready pod -l app=elasticsearch -n rd-microservices --timeout=300s
```

### 7.2 Accéder à Kibana

**Si en local (Docker Compose) :**
- http://localhost:5601

**Si sur Kubernetes :**
```bash
kubectl port-forward svc/kibana 5601:5601 -n rd-microservices
```
- http://localhost:5601

### 7.3 Configurer les Index Patterns

1. Management → Stack Management → Index Patterns
2. Cliquer sur **Create index pattern**
3. Pattern : `microservices-logs-*`
4. Time field : `@timestamp`
5. Cliquer sur **Create index pattern**

### 7.4 Voir les Logs

1. Analytics → Discover
2. Sélectionner l'index pattern `microservices-logs-*`
3. Les logs devraient apparaître

**Note :** Les logs n'apparaîtront que si les services envoient des logs à Logstash.

---

## 🔄 ÉTAPE 8 : Configuration GitLab CI/CD (20-30 min)

### 8.1 Créer un Projet GitLab

**Option A : GitLab.com (Cloud)**
1. Aller sur https://gitlab.com
2. Créer un compte (si nécessaire)
3. New project → Create blank project
4. Nom : `rd-microservices`

**Option B : GitLab Self-Hosted**
- Suivre `INSTALLATION_GUIDE.md` section "GitLab CI/CD"

### 8.2 Push le Code

```bash
# Initialiser Git (si pas déjà fait)
git init
git add .
git commit -m "Initial commit with Keycloak, NGINX, CI/CD, Grafana, ELK"

# Ajouter le remote GitLab
git remote add origin https://gitlab.com/votre-username/rd-microservices.git

# Push
git push -u origin main
```

### 8.3 Configurer les Variables CI/CD

1. Dans GitLab : Settings → CI/CD → Variables
2. Ajouter les variables suivantes :

| Variable | Valeur | Exemple |
|----------|--------|---------|
| `CI_REGISTRY_USER` | Votre utilisateur Docker registry | `gitlab-ci-token` |
| `CI_REGISTRY_PASSWORD` | Votre token | `[token]` |
| `CI_REGISTRY` | URL du registry | `registry.gitlab.com` |
| `KUBE_CONTEXT_STAGING` | Contexte K8s staging | `minikube` |
| `KUBE_CONTEXT_PRODUCTION` | Contexte K8s production | `production-cluster` |

**Note :** Pour GitLab.com, `CI_REGISTRY_USER` = `gitlab-ci-token` et `CI_REGISTRY_PASSWORD` = token du projet.

### 8.4 Installer GitLab Runner (Optionnel pour GitLab.com)

**Si GitLab.com :** Les runners partagés sont disponibles, pas besoin d'installer.

**Si Self-Hosted :**
```bash
# Linux
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner

# Enregistrer
sudo gitlab-runner register
# Suivre les instructions avec le token du projet
```

### 8.5 Tester le Pipeline

1. Dans GitLab : CI/CD → Pipelines
2. Le pipeline devrait démarrer automatiquement
3. Vérifier que les stages passent

**✅ Si le pipeline passe :** CI/CD est configuré

---

## ✅ ÉTAPE 9 : Tests Finaux (15-20 min)

### 9.1 Tester l'Authentification

```bash
# Obtenir un token Keycloak
TOKEN=$(curl -s -X POST http://localhost:8090/realms/rd-microservices/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=rd-gateway" \
  -d "client_secret=rd-gateway-secret-change-in-production" \
  -d "grant_type=client_credentials" \
  -d "username=researcher1" \
  -d "password=password123" | jq -r '.access_token')

# Tester une requête authentifiée
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/projects/
```

### 9.2 Tester les Services

```bash
# Health checks
curl http://localhost:8080/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health

# Via NGINX Gateway
curl http://localhost:8080/api/auth/health
```

### 9.3 Vérifier Prometheus

1. Accéder : http://localhost:9090
2. Status → Targets
3. Vérifier que tous les services sont "UP"

### 9.4 Vérifier Grafana

1. Accéder : http://localhost:3000
2. Vérifier que le dashboard affiche des métriques

### 9.5 Vérifier Kibana

1. Accéder : http://localhost:5601
2. Vérifier que les logs apparaissent (si configurés)

---

## 📋 Checklist Finale

### Installation
- [ ] Java 17+, Maven, Git installés
- [ ] Docker + Docker Compose installés
- [ ] Kubernetes (Minikube/kind/k3d) installé
- [ ] kubectl installé et configuré

### Configuration
- [ ] Keycloak démarré et realm importé
- [ ] Secrets Kubernetes créés
- [ ] Services déployés sur Kubernetes
- [ ] NGINX déployé et fonctionnel

### Monitoring
- [ ] Prometheus déployé et collecte des métriques
- [ ] Grafana configuré avec Prometheus
- [ ] Dashboard Grafana importé
- [ ] ELK Stack déployé (optionnel)

### CI/CD
- [ ] Projet GitLab créé
- [ ] Code pushé
- [ ] Variables CI/CD configurées
- [ ] Pipeline testé et fonctionnel

### Tests
- [ ] Authentification Keycloak fonctionnelle
- [ ] Services accessibles via NGINX
- [ ] Métriques visibles dans Prometheus
- [ ] Dashboard Grafana fonctionnel

---

## 🎯 Prochaines Actions Recommandées

1. **Sécuriser** : Changer tous les mots de passe par défaut
2. **Documenter** : Ajouter des notes sur votre configuration spécifique
3. **Optimiser** : Ajuster les ressources CPU/Memory selon vos besoins
4. **Monitorer** : Configurer des alertes dans Prometheus/Grafana
5. **Backup** : Mettre en place des backups pour les bases de données

---

## 🆘 En Cas de Problème

### Services ne démarrent pas
```bash
# Vérifier les logs
docker-compose logs <service>
# ou
kubectl logs <pod-name> -n rd-microservices
```

### Keycloak ne démarre pas
```bash
# Vérifier la base de données
docker-compose logs keycloak-db
# ou
kubectl logs deployment/keycloak-db -n rd-microservices
```

### NGINX erreur 502
- Vérifier que les services backend sont démarrés
- Vérifier la configuration NGINX
- Vérifier les logs : `kubectl logs deployment/nginx-gateway -n rd-microservices`

### Prometheus pas de métriques
- Vérifier que les services exposent `/actuator/prometheus`
- Vérifier la configuration Prometheus
- Vérifier les targets : http://localhost:9090/targets

---

## 📚 Documentation de Référence

- `INSTALLATION_GUIDE.md` - Guide d'installation détaillé
- `SETUP_KEYCLOAK_NGINX.md` - Guide de migration
- `MIGRATION_COMPLETE.md` - Récapitulatif complet
- `DEPLOYMENT.md` - Guide de déploiement
- `README.md` - Documentation principale

---

**🎉 Bonne chance avec votre projet !**

