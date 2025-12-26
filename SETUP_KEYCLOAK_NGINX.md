# 🔄 Migration vers Keycloak et NGINX

## 📋 Changements Effectués

### 1. ✅ Keycloak (remplace JWT)

**Fichiers créés :**
- `keycloak/docker-compose.yml` - Keycloak pour développement
- `keycloak/k8s/keycloak.yaml` - Keycloak pour Kubernetes
- `keycloak/realm-config/rd-realm.json` - Configuration du realm

**Fichiers modifiés :**
- `auth-service/pom.xml` - Ajout dépendances Keycloak
- `auth-service/src/main/java/com/rd/auth/config/KeycloakConfig.java` - Configuration Keycloak
- `auth-service/src/main/resources/application-keycloak.yml` - Configuration Keycloak

### 2. ✅ NGINX (remplace Spring Cloud Gateway)

**Fichiers créés :**
- `nginx/nginx.conf` - Configuration NGINX
- `nginx/Dockerfile` - Image Docker NGINX
- `nginx/k8s/nginx-gateway.yaml` - Déploiement Kubernetes

### 3. ✅ GitLab CI/CD

**Fichier créé :**
- `.gitlab-ci.yml` - Pipeline complet avec build, test, build images, deploy

### 4. ✅ Grafana

**Fichiers créés :**
- `monitoring/grafana/dashboards/microservices-dashboard.json` - Dashboard
- `monitoring/grafana/k8s/grafana.yaml` - Déploiement Kubernetes

### 5. ✅ ELK Stack

**Fichiers créés :**
- `monitoring/elk/k8s/elasticsearch.yaml` - Elasticsearch
- `monitoring/elk/k8s/logstash.yaml` - Logstash
- `monitoring/elk/k8s/kibana.yaml` - Kibana
- `monitoring/elk/filebeat-config.yaml` - Filebeat (optionnel)

---

## 🚀 Étapes de Migration

### Étape 1 : Installer Keycloak

**Développement (Docker Compose) :**
```bash
cd keycloak
docker-compose up -d

# Accéder à Keycloak
# http://localhost:8090
# Admin / admin123
```

**Production (Kubernetes) :**
```bash
# Créer le secret
kubectl create secret generic keycloak-secret \
  --from-literal=admin-password='VotreMotDePasseAdmin' \
  --from-literal=db-password='VotreMotDePasseDB' \
  -n rd-microservices

# Déployer Keycloak
kubectl apply -f keycloak/k8s/keycloak.yaml -n rd-microservices
```

### Étape 2 : Configurer Keycloak Realm

1. Accéder à Keycloak : http://localhost:8090
2. Se connecter : admin / admin123
3. Importer le realm :
   - Administration → Import realm
   - Sélectionner `keycloak/realm-config/rd-realm.json`
4. Vérifier les clients et utilisateurs créés

### Étape 3 : Mettre à jour Auth-Service

**Option A : Utiliser Keycloak (Nouveau)**
```bash
# Modifier application.yml pour utiliser application-keycloak.yml
# Ou renommer application-keycloak.yml en application.yml
```

**Option B : Garder JWT (Temporaire)**
- L'ancien code JWT reste fonctionnel
- Migration progressive possible

### Étape 4 : Déployer NGINX

**Développement :**
```bash
cd nginx
docker build -t nginx-gateway .
docker run -d -p 8080:8080 --network rd-network nginx-gateway
```

**Production (Kubernetes) :**
```bash
# Build et push l'image NGINX
docker build -t your-registry/nginx-gateway:latest ./nginx
docker push your-registry/nginx-gateway:latest

# Déployer
kubectl apply -f nginx/k8s/nginx-gateway.yaml -n rd-microservices
```

### Étape 5 : Configurer GitLab CI/CD

1. **Créer un projet GitLab**
2. **Push le code** avec `.gitlab-ci.yml`
3. **Configurer les variables CI/CD** :
   - Settings → CI/CD → Variables
   - Ajouter :
     - `CI_REGISTRY_USER`
     - `CI_REGISTRY_PASSWORD`
     - `CI_REGISTRY`
     - `KUBE_CONTEXT_STAGING`
     - `KUBE_CONTEXT_PRODUCTION`

4. **Installer GitLab Runner** (voir `INSTALLATION_GUIDE.md`)

### Étape 6 : Déployer Prometheus

```bash
kubectl apply -f monitoring/prometheus/k8s/prometheus.yaml -n rd-microservices
```

### Étape 7 : Déployer Grafana

```bash
# Créer le secret
kubectl create secret generic grafana-secret \
  --from-literal=admin-password='VotreMotDePasseGrafana' \
  -n rd-microservices

# Déployer
kubectl apply -f monitoring/grafana/k8s/grafana.yaml -n rd-microservices

# Accéder : http://localhost:3000
# Login : admin / VotreMotDePasseGrafana
# Ajouter Prometheus comme datasource : http://prometheus:9090
```

### Étape 8 : Déployer ELK Stack

```bash
kubectl apply -f monitoring/elk/k8s/ -n rd-microservices

# Attendre qu'Elasticsearch soit prêt
kubectl wait --for=condition=ready pod -l app=elasticsearch -n rd-microservices --timeout=300s

# Accéder à Kibana : http://localhost:5601
```

---

## 🔧 Modifications du Code Nécessaires

### Auth-Service : Utiliser Keycloak

**À modifier :**
1. `AuthService.java` - Utiliser Keycloak Admin Client au lieu de JWT
2. `AuthController.java` - Endpoints pour obtenir tokens Keycloak
3. Supprimer `JwtService.java` (remplacé par Keycloak)

**Nouveau flux :**
- Login → Keycloak retourne un token OAuth2
- Validation → Keycloak valide le token
- Rôles → Récupérés depuis Keycloak

### Services : Supprimer dépendance Gateway

Les services n'ont plus besoin de Spring Cloud Gateway, ils sont accessibles directement via NGINX.

---

## 📝 Checklist de Migration

- [ ] Keycloak installé et démarré
- [ ] Realm Keycloak importé
- [ ] Auth-Service modifié pour utiliser Keycloak
- [ ] NGINX déployé et configuré
- [ ] Ancien Gateway-Service retiré (ou gardé en parallèle)
- [ ] GitLab CI/CD configuré
- [ ] Prometheus déployé
- [ ] Grafana déployé et configuré
- [ ] ELK Stack déployé (optionnel)
- [ ] Tests effectués

---

## ⚠️ Notes Importantes

1. **Migration progressive possible** : Garder JWT et Keycloak en parallèle pendant la transition
2. **NGINX auth_request** : Nécessite le module `ngx_http_auth_request_module` (inclus dans nginx:alpine)
3. **Keycloak en production** : Utiliser `start` au lieu de `start-dev`
4. **Secrets** : Changer tous les mots de passe par défaut

Voir `INSTALLATION_GUIDE.md` pour les installations détaillées.

