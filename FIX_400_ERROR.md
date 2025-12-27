# Guide de résolution de l'erreur 400 Bad Request

## Problème
L'erreur **400 Bad Request** signifie que la requête arrive bien au service, mais qu'elle est rejetée pour une raison de validation ou de format.

## Causes possibles

### 1. Validation des champs échouée
Les contraintes de validation dans `RegisterRequest` :
- `username`: 3-50 caractères, non vide
- `email`: format email valide, non vide
- `password`: minimum 6 caractères, non vide

### 2. Base de données non accessible
- La table `users` n'existe pas
- Problème de connexion à PostgreSQL
- Flyway n'a pas exécuté les migrations

### 3. Format JSON incorrect
- Champs manquants
- Types incorrects

## Solutions

### Étape 1: Vérifier les logs
```powershell
# Voir les logs détaillés
docker logs auth-service --tail 100

# Voir les erreurs spécifiques
docker logs auth-service 2>&1 | Select-String -Pattern "error|exception|400" -CaseSensitive:$false
```

### Étape 2: Vérifier la base de données
```powershell
# Vérifier que postgres-auth est démarré
docker ps | Select-String "postgres-auth"

# Vérifier la connexion
docker exec postgres-auth psql -U postgres -d auth_db -c "\dt"

# Vérifier si la table users existe
docker exec postgres-auth psql -U postgres -d auth_db -c "SELECT * FROM users LIMIT 1;"
```

### Étape 3: Tester avec le script amélioré
```powershell
.\scripts\test-register.ps1
```

### Étape 4: Tester directement auth-service (bypass NGINX)
```powershell
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8081/auth/register" `
    -Method Post -ContentType "application/json" -Body $body
```

### Étape 5: Vérifier les migrations Flyway
```powershell
# Vérifier les logs Flyway
docker logs auth-service | Select-String -Pattern "flyway|migration"

# Si les migrations n'ont pas été exécutées, redémarrer le service
docker-compose restart auth-service
```

### Étape 6: Rebuild si nécessaire
```powershell
# Rebuild auth-service
docker-compose up -d --build auth-service

# Attendre 30 secondes
Start-Sleep -Seconds 30

# Retester
.\scripts\test-register.ps1
```

## Format JSON correct

```json
{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
}
```

## Commandes de diagnostic rapide

```powershell
# 1. Statut des services
docker-compose ps

# 2. Logs auth-service
docker logs auth-service --tail 50

# 3. Test de santé
Invoke-WebRequest -Uri "http://localhost:8081/actuator/health"

# 4. Test de la base de données
docker exec postgres-auth psql -U postgres -d auth_db -c "SELECT COUNT(*) FROM users;"

# 5. Test d'inscription avec gestion d'erreurs
.\scripts\test-register.ps1
```

