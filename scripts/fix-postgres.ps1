# Script PowerShell pour corriger les problèmes PostgreSQL

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Correction des Problèmes PostgreSQL" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Arrêter tous les conteneurs
Write-Host "1. Arrêt de tous les conteneurs..." -ForegroundColor Yellow
docker-compose down
Write-Host ""

# 2. Vérifier les ports
Write-Host "2. Vérification des ports..." -ForegroundColor Yellow
Write-Host "Ports PostgreSQL utilisés:" -ForegroundColor Yellow
$ports = @(5433, 5434, 5435, 5436)
foreach ($port in $ports) {
    $result = netstat -ano | findstr ":$port"
    if ($result) {
        Write-Host "  Port $port est utilisé !" -ForegroundColor Red
        Write-Host "  $result" -ForegroundColor Yellow
    } else {
        Write-Host "  Port $port est libre" -ForegroundColor Green
    }
}
Write-Host ""

# 3. Option : Supprimer les volumes (décommenter si nécessaire)
Write-Host "3. Pour supprimer les volumes, décommenter les lignes suivantes dans le script" -ForegroundColor Yellow
# docker volume rm miroservicesrd_postgres-auth-data
# docker volume rm miroservicesrd_postgres-project-data
# docker volume rm miroservicesrd_postgres-validation-data
# docker volume rm miroservicesrd_postgres-finance-data
# docker volume rm miroservicesrd_keycloak-db-data
Write-Host ""

# 4. Démarrer uniquement les bases de données
Write-Host "4. Démarrage des conteneurs PostgreSQL uniquement..." -ForegroundColor Yellow
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance keycloak-db
Write-Host ""

# 5. Attendre
Write-Host "5. Attente que les bases soient prêtes (30 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
Write-Host ""

# 6. Vérifier le statut
Write-Host "6. Vérification du statut..." -ForegroundColor Yellow
docker-compose ps | Select-String "postgres"
Write-Host ""

# 7. Afficher les logs
Write-Host "7. Logs de postgres-auth (dernières 20 lignes):" -ForegroundColor Yellow
docker-compose logs --tail=20 postgres-auth
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Correction terminée" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si les conteneurs sont toujours en erreur, vérifiez les logs avec:" -ForegroundColor Yellow
Write-Host "  docker-compose logs postgres-auth" -ForegroundColor White
Write-Host "  docker-compose logs postgres-project" -ForegroundColor White

