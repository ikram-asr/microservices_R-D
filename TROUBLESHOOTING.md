# 🔧 Guide de Dépannage - Problèmes PostgreSQL

## ❌ Problème : Conteneurs PostgreSQL en Erreur

### Symptômes
```
✘ Container postgres-finance      Error
✘ Container postgres-auth          Error
✘ Container postgres-validation   Error
✘ Container postgres-project      Error
✘ Container keycloak-db           Error
```

---

## 🔍 Solution 1 : Vérifier les Logs

**Windows PowerShell :**
```powershell
docker-compose logs postgres-auth
docker-compose logs postgres-project
docker-compose logs postgres-finance
docker-compose logs postgres-validation
docker-compose logs keycloak-db
```

**Linux/Mac :**
```bash
docker-compose logs postgres-auth | tail -50
docker-compose logs postgres-project | tail -50
```

---

## 🔍 Solution 2 : Vérifier les Ports en Conflit

Les conteneurs PostgreSQL utilisent les ports :
- `5433` → postgres-auth
- `5434` → postgres-project
- `5435` → postgres-validation
- `5436` → postgres-finance

**Vérifier si les ports sont utilisés :**

**Windows PowerShell :**
```powershell
netstat -ano | findstr "5433"
netstat -ano | findstr "5434"
netstat -ano | findstr "5435"
netstat -ano | findstr "5436"
```

**Linux/Mac :**
```bash
lsof -i :5433
lsof -i :5434
lsof -i :5435
lsof -i :5436
```

**Si un port est utilisé :**
- Arrêter le service qui utilise le port
- Ou modifier les ports dans `docker-compose.yml`

---

## 🔍 Solution 3 : Nettoyer et Redémarrer

### Étape 1 : Arrêter tous les conteneurs
```bash
docker-compose down
```

### Étape 2 : Supprimer les volumes (⚠️ Supprime les données)
```bash
# Windows PowerShell
docker volume rm miroservicesrd_postgres-auth-data
docker volume rm miroservicesrd_postgres-project-data
docker volume rm miroservicesrd_postgres-validation-data
docker volume rm miroservicesrd_postgres-finance-data
docker volume rm miroservicesrd_keycloak-db-data

# Linux/Mac
docker volume rm miroservicesrd_postgres-auth-data \
  miroservicesrd_postgres-project-data \
  miroservicesrd_postgres-validation-data \
  miroservicesrd_postgres-finance-data \
  miroservicesrd_keycloak-db-data
```

### Étape 3 : Redémarrer uniquement les bases de données
```bash
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance keycloak-db
```

### Étape 4 : Attendre et vérifier
```bash
# Attendre 30 secondes
sleep 30

# Vérifier le statut
docker-compose ps
```

---

## 🔍 Solution 4 : Démarrer les Bases une par une

Si le problème persiste, démarrer les bases une par une :

```bash
# 1. Démarrer postgres-auth
docker-compose up -d postgres-auth
sleep 10

# 2. Vérifier les logs
docker-compose logs postgres-auth

# 3. Si OK, démarrer les autres
docker-compose up -d postgres-project
sleep 10
docker-compose up -d postgres-validation
sleep 10
docker-compose up -d postgres-finance
sleep 10
docker-compose up -d keycloak-db
```

---

## 🔍 Solution 5 : Vérifier les Permissions (Linux/Mac)

Si vous êtes sur Linux/Mac et avez des problèmes de permissions :

```bash
# Vérifier les permissions des volumes
docker volume inspect miroservicesrd_postgres-auth-data

# Si nécessaire, corriger les permissions
sudo chown -R 999:999 /var/lib/docker/volumes/miroservicesrd_postgres-auth-data/_data
```

---

## 🔍 Solution 6 : Problème avec PostgreSQL Local

Si vous avez PostgreSQL installé localement sur le port 5432 :

**Option A : Arrêter PostgreSQL local**
```bash
# Windows
net stop postgresql-x64-14

# Linux
sudo systemctl stop postgresql

# macOS
brew services stop postgresql@14
```

**Option B : Modifier les ports dans docker-compose.yml**

Les ports sont déjà différents (5433-5436), donc normalement pas de conflit.

---

## 🔍 Solution 7 : Problème de Mémoire

Si Docker n'a pas assez de mémoire :

1. Ouvrir Docker Desktop
2. Settings → Resources
3. Augmenter la mémoire allouée (minimum 4GB recommandé)

---

## 🔍 Solution 8 : Réduire les Healthcheck Retries

Si les healthchecks échouent trop rapidement, modifier `docker-compose.yml` :

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U auth_user -d auth_db"]
  interval: 10s
  timeout: 5s
  retries: 10  # Augmenter de 5 à 10
  start_period: 30s  # Ajouter cette ligne
```

---

## ✅ Solution Rapide (Recommandée)

**Exécuter ces commandes dans l'ordre :**

```bash
# 1. Arrêter tout
docker-compose down

# 2. Vérifier les ports (optionnel)
# netstat -ano | findstr "5433"  # Windows
# lsof -i :5433  # Linux/Mac

# 3. Démarrer uniquement les bases de données
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance keycloak-db

# 4. Attendre 30 secondes
sleep 30

# 5. Vérifier les logs
docker-compose logs postgres-auth | tail -20

# 6. Si les logs montrent "database system is ready to accept connections"
# Alors démarrer les autres services
docker-compose up -d
```

---

## 📋 Checklist de Diagnostic

- [ ] Vérifier les logs de chaque conteneur PostgreSQL
- [ ] Vérifier que les ports 5433-5436 ne sont pas utilisés
- [ ] Vérifier l'espace disque disponible
- [ ] Vérifier la mémoire Docker disponible
- [ ] Vérifier qu'il n'y a pas de PostgreSQL local qui interfère
- [ ] Essayer de démarrer les bases une par une
- [ ] Nettoyer les volumes et redémarrer

---

## 🆘 Si Rien ne Fonctionne

1. **Vérifier la version de Docker :**
   ```bash
   docker --version
   docker-compose --version
   ```
   Doit être Docker 20.10+ et Docker Compose 2.0+

2. **Vérifier les logs Docker :**
   ```bash
   docker system events
   ```

3. **Redémarrer Docker Desktop** (Windows/Mac)

4. **Créer un fichier de test minimal :**
   Créer `docker-compose.test.yml` avec un seul PostgreSQL pour tester :
   ```yaml
   version: '3.8'
   services:
     postgres-test:
       image: postgres:14-alpine
       environment:
         POSTGRES_USER: test
         POSTGRES_PASSWORD: test
         POSTGRES_DB: test
       ports:
         - "5437:5432"
   ```
   Puis : `docker-compose -f docker-compose.test.yml up -d`

---

## 📞 Informations à Fournir en Cas de Problème Persistant

Si le problème persiste, fournir :

1. **Logs complets :**
   ```bash
   docker-compose logs > logs.txt
   ```

2. **Version de Docker :**
   ```bash
   docker --version
   docker-compose --version
   ```

3. **Système d'exploitation :**
   ```bash
   # Windows
   systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
   
   # Linux
   uname -a
   lsb_release -a
   
   # Mac
   sw_vers
   ```

4. **Espace disque :**
   ```bash
   # Windows
   fsutil volume diskfree C:
   
   # Linux/Mac
   df -h
   ```

---

## ✅ Après Correction

Une fois que les bases de données démarrent correctement :

1. Vérifier que tous les conteneurs sont "healthy" :
   ```bash
   docker-compose ps
   ```

2. Tester la connexion :
   ```bash
   docker-compose exec postgres-auth pg_isready -U auth_user
   ```

3. Démarrer les autres services :
   ```bash
   docker-compose up -d
   ```

4. Vérifier que tout fonctionne :
   ```bash
   docker-compose ps
   curl http://localhost:8080/health
   ```

