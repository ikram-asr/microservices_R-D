# Script PowerShell pour redémarrer tous les services à zéro

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Redémarrage Complet des Services" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Arrêter tous les conteneurs
Write-Host "1. Arrêt de tous les conteneurs..." -ForegroundColor Yellow
docker-compose down
Write-Host "✓ Conteneurs arrêtés" -ForegroundColor Green
Write-Host ""

# 2. Optionnel : Supprimer les volumes (décommenter si nécessaire)
Write-Host "2. Pour supprimer les volumes et données, décommenter les lignes suivantes:" -ForegroundColor Yellow
# docker volume rm miroservicesrd_postgres-auth-data
# docker volume rm miroservicesrd_postgres-project-data
# docker volume rm miroservicesrd_postgres-validation-data
# docker volume rm miroservicesrd_postgres-finance-data
# docker volume rm miroservicesrd_keycloak-db-data
# docker volume rm miroservicesrd_prometheus-data
# docker volume rm miroservicesrd_grafana-data
# docker volume rm miroservicesrd_elasticsearch-data
Write-Host ""

# 3. Nettoyer les images (optionnel)
Write-Host "3. Nettoyage des images non utilisées..." -ForegroundColor Yellow
docker system prune -f
Write-Host "✓ Nettoyage terminé" -ForegroundColor Green
Write-Host ""

# 4. Vérifier que le réseau existe
Write-Host "4. Vérification du réseau Docker..." -ForegroundColor Yellow
$networkExists = docker network ls | Select-String "rd-network"
if (-not $networkExists) {
    Write-Host "Création du réseau rd-network..." -ForegroundColor Yellow
    docker network create rd-network
    Write-Host "✓ Réseau créé" -ForegroundColor Green
} else {
    Write-Host "✓ Réseau existe déjà" -ForegroundColor Green
}
Write-Host ""

# 5. Build des images
Write-Host "5. Build des images Docker..." -ForegroundColor Yellow
docker-compose build --no-cache
Write-Host "✓ Build terminé" -ForegroundColor Green
Write-Host ""

# 6. Démarrer les bases de données d'abord
Write-Host "6. Démarrage des bases de données PostgreSQL..." -ForegroundColor Yellow
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance keycloak-db
Write-Host "✓ Bases de données démarrées" -ForegroundColor Green
Write-Host ""

# 7. Attendre que les bases soient prêtes
Write-Host "7. Attente que les bases soient prêtes (30 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
Write-Host "✓ Attente terminée" -ForegroundColor Green
Write-Host ""

# 8. Vérifier les bases de données
Write-Host "8. Vérification des bases de données..." -ForegroundColor Yellow
$postgresContainers = @("postgres-auth", "postgres-project", "postgres-validation", "postgres-finance", "keycloak-db")
foreach ($container in $postgresContainers) {
    $status = docker ps --filter "name=$container" --format "{{.Status}}"
    if ($status) {
        Write-Host "  ✓ $container : $status" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container : Non démarré" -ForegroundColor Red
    }
}
Write-Host ""

# 9. Démarrer tous les services
Write-Host "9. Démarrage de tous les services..." -ForegroundColor Yellow
docker-compose up -d
Write-Host "✓ Services démarrés" -ForegroundColor Green
Write-Host ""

# 10. Attendre que les services soient prêts
Write-Host "10. Attente que les services soient prêts (20 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20
Write-Host "✓ Attente terminée" -ForegroundColor Green
Write-Host ""

# 11. Vérifier le statut de tous les services
Write-Host "11. Statut de tous les services:" -ForegroundColor Yellow
docker-compose ps
Write-Host ""

# 12. Vérifier les health checks
Write-Host "12. Vérification des health checks..." -ForegroundColor Yellow
Write-Host ""

$services = @(
    @{Name="NGINX Gateway"; Url="http://localhost:8085/health"},
    @{Name="Auth Service"; Url="http://localhost:8081/actuator/health"},
    @{Name="Project Service"; Url="http://localhost:8082/actuator/health"},
    @{Name="Validation Service"; Url="http://localhost:8083/actuator/health"},
    @{Name="Finance Service"; Url="http://localhost:8084/actuator/health"},
    @{Name="Keycloak"; Url="http://localhost:8090/health"},
    @{Name="Prometheus"; Url="http://localhost:9090/-/healthy"},
    @{Name="Grafana"; Url="http://localhost:3000/api/health"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $($service.Name) : OK" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $($service.Name) : Status $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ✗ $($service.Name) : Non accessible" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Redémarrage terminé !" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URLs des services:" -ForegroundColor Yellow
Write-Host "  - NGINX Gateway: http://localhost:8085" -ForegroundColor White
Write-Host "  - Auth Service: http://localhost:8081" -ForegroundColor White
Write-Host "  - Project Service: http://localhost:8082" -ForegroundColor White
Write-Host "  - Validation Service: http://localhost:8083" -ForegroundColor White
Write-Host "  - Finance Service: http://localhost:8084" -ForegroundColor White
Write-Host "  - Keycloak: http://localhost:8090" -ForegroundColor White
Write-Host "  - Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  - Grafana: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Pour tester les APIs, voir API_TESTING_GUIDE.md" -ForegroundColor Yellow

