# 🔌 Vérification des Ports - Configuration Complète

## 📋 Ports Configurés

### Services Applicatifs

| Service | Port Host | Port Container | URL d'Accès |
|---------|----------|----------------|-------------|
| **NGINX Gateway** | `8085` | `8080` | `http://localhost:8085` |
| **Auth Service** | `8081` | `8081` | `http://localhost:8081` |
| **Project Service** | `8082` | `8082` | `http://localhost:8082` |
| **Validation Service** | `8083` | `8083` | `http://localhost:8083` |
| **Finance Service** | `8084` | `8084` | `http://localhost:8084` |

### Services d'Infrastructure

| Service | Port Host | Port Container | URL d'Accès |
|---------|----------|----------------|-------------|
| **Keycloak** | `8090` | `8080` | `http://localhost:8090` |
| **Prometheus** | `9090` | `9090` | `http://localhost:9090` |
| **Grafana** | `3000` | `3000` | `http://localhost:3000` |
| **Kibana** | `5601` | `5601` | `http://localhost:5601` |
| **Elasticsearch** | `9200` | `9200` | `http://localhost:9200` |
| **Logstash** | `5044` | `5044` | `http://localhost:5044` |

### Bases de Données PostgreSQL

| Base de Données | Port Host | Port Container | Connexion |
|----------------|-----------|----------------|-----------|
| **postgres-auth** | `5433` | `5432` | `localhost:5433` |
| **postgres-project** | `5434` | `5432` | `localhost:5434` |
| **postgres-validation** | `5435` | `5432` | `localhost:5435` |
| **postgres-finance** | `5436` | `5432` | `localhost:5436` |
| **keycloak-db** | (interne) | `5432` | `keycloak-db:5432` |

---

## ✅ Vérification de Cohérence

### 1. NGINX Gateway

**Configuration Docker Compose :**
```yaml
nginx-gateway:
  ports:
    - "8085:8080"  # ✅ Port 8085 sur host, 8080 dans container
```

**Configuration NGINX :**
```nginx
server {
    listen 8080;  # ✅ CORRECT
    ...
}
```

**Upstreams NGINX :**
```nginx
upstream auth-service {
    server auth-service:8081;  # ✅ CORRECT
}
upstream project-service {
    server project-service:8082;  # ✅ CORRECT
}
upstream validation-service {
    server validation-service:8083;  # ✅ CORRECT
}
upstream finance-service {
    server finance-service:8084;  # ✅ CORRECT
}
```

**✅ Tous les ports sont cohérents !**

---

## 🔍 Comment Vérifier les Ports

### Vérifier les Ports Utilisés

**Windows PowerShell :**
```powershell
netstat -ano | findstr "8080 8081 8082 8083 8084 8090 9090 3000"
```

**Linux/Mac :**
```bash
lsof -i :8080 -i :8081 -i :8082 -i :8083 -i :8084 -i :8090 -i :9090 -i :3000
```

### Vérifier les Conteneurs Docker

```bash
docker-compose ps
```

### Vérifier les Ports Mappés

```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

---

## 🚨 Problèmes de Ports Courants

### 1. Port Déjà Utilisé

**Symptôme :** Erreur `bind: address already in use`

**Solution :**
```bash
# Trouver le processus qui utilise le port
# Windows
netstat -ano | findstr "8080"

# Linux/Mac
lsof -i :8080

# Arrêter le processus ou changer le port dans docker-compose.yml
```

### 2. Port Incorrect dans l'URL

**Symptôme :** Erreur 404 ou connexion refusée

**Solution :**
- Utiliser le port **8080** pour NGINX (pas 8085)
- Vérifier que vous utilisez le bon port selon le service

### 3. Ports en Conflit entre Services

**Symptôme :** Un service ne démarre pas

**Solution :**
- Vérifier qu'aucun port n'est utilisé deux fois
- Vérifier la configuration dans `docker-compose.yml`

---

## 📝 URLs Correctes pour Tester

### Via NGINX Gateway (Port 8085)

```bash
# Auth
POST http://localhost:8085/api/auth/register
POST http://localhost:8085/api/auth/login

# Projects
GET http://localhost:8085/api/projects
POST http://localhost:8085/api/projects

# Validations
GET http://localhost:8085/api/validations
POST http://localhost:8085/api/validations

# Finance
GET http://localhost:8085/api/finance/budgets
POST http://localhost:8085/api/finance/budgets
```

### Directement sur les Services

```bash
# Auth Service (Port 8081)
POST http://localhost:8081/auth/register
POST http://localhost:8081/auth/login

# Project Service (Port 8082)
GET http://localhost:8082/projects
POST http://localhost:8082/projects

# Validation Service (Port 8083)
GET http://localhost:8083/validations
POST http://localhost:8083/validations

# Finance Service (Port 8084)
GET http://localhost:8084/finance/budgets
POST http://localhost:8084/finance/budgets
```

---

## ✅ Checklist de Vérification

- [ ] NGINX écoute sur le port 8085 (host)
- [ ] Auth Service écoute sur le port 8081 (host)
- [ ] Project Service écoute sur le port 8082 (host)
- [ ] Validation Service écoute sur le port 8083 (host)
- [ ] Finance Service écoute sur le port 8084 (host)
- [ ] Keycloak écoute sur le port 8090 (host)
- [ ] Prometheus écoute sur le port 9090 (host)
- [ ] Grafana écoute sur le port 3000 (host)
- [ ] Aucun port en conflit
- [ ] Les upstreams NGINX pointent vers les bons ports

---

## 🔧 Correction Appliquée

**Avant :**
```yaml
nginx-gateway:
  ports:
    - "8085:8080"  # ❌ INCOHÉRENT
```

**Après :**
```yaml
nginx-gateway:
  ports:
    - "8080:8080"  # ✅ CORRIGÉ
```

**Maintenant, utilisez toujours `http://localhost:8085` pour accéder via NGINX !**

---

## 📚 Références

- `docker-compose.yml` - Configuration des ports
- `nginx/nginx.conf` - Configuration NGINX et upstreams
- `API_TESTING_GUIDE.md` - Guide de test des APIs

