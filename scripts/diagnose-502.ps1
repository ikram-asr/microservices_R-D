# Script de diagnostic pour erreur 502 Bad Gateway
Write-Host "=== DIAGNOSTIC 502 BAD GATEWAY ===" -ForegroundColor Yellow
Write-Host ""

# 1. Vérifier le statut des conteneurs
Write-Host "1. Statut des conteneurs:" -ForegroundColor Cyan
docker-compose ps
Write-Host ""

# 2. Vérifier si auth-service est démarré
Write-Host "2. Vérification auth-service:" -ForegroundColor Cyan
$authStatus = docker ps --filter "name=auth-service" --format "{{.Status}}"
if ($authStatus) {
    Write-Host "  ✓ auth-service: $authStatus" -ForegroundColor Green
} else {
    Write-Host "  ✗ auth-service: NON DÉMARRÉ" -ForegroundColor Red
}
Write-Host ""

# 3. Vérifier si nginx-gateway est démarré
Write-Host "3. Vérification nginx-gateway:" -ForegroundColor Cyan
$nginxStatus = docker ps --filter "name=nginx-gateway" --format "{{.Status}}"
if ($nginxStatus) {
    Write-Host "  ✓ nginx-gateway: $nginxStatus" -ForegroundColor Green
} else {
    Write-Host "  ✗ nginx-gateway: NON DÉMARRÉ" -ForegroundColor Red
}
Write-Host ""

# 4. Logs NGINX (dernières 20 lignes)
Write-Host "4. Logs NGINX (dernières 20 lignes):" -ForegroundColor Cyan
docker logs nginx-gateway --tail 20
Write-Host ""

# 5. Logs auth-service (dernières 30 lignes)
Write-Host "5. Logs auth-service (dernières 30 lignes):" -ForegroundColor Cyan
docker logs auth-service --tail 30
Write-Host ""

# 6. Tester la connectivité depuis NGINX vers auth-service
Write-Host "6. Test de connectivité NGINX -> auth-service:" -ForegroundColor Cyan
docker exec nginx-gateway wget -O- --timeout=5 http://auth-service:8081/actuator/health 2>&1
Write-Host ""

# 7. Tester directement auth-service
Write-Host "7. Test direct auth-service:" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ auth-service répond: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "  Contenu: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ auth-service ne répond pas: $_" -ForegroundColor Red
}
Write-Host ""

# 8. Vérifier le réseau Docker
Write-Host "8. Vérification réseau Docker:" -ForegroundColor Cyan
docker network inspect rd-network --format "{{range .Containers}}{{.Name}} {{end}}" 2>&1
Write-Host ""

# 9. Vérifier postgres-auth
Write-Host "9. Vérification postgres-auth:" -ForegroundColor Cyan
$pgStatus = docker ps --filter "name=postgres-auth" --format "{{.Status}}"
if ($pgStatus) {
    Write-Host "  ✓ postgres-auth: $pgStatus" -ForegroundColor Green
} else {
    Write-Host "  ✗ postgres-auth: NON DÉMARRÉ" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== FIN DU DIAGNOSTIC ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Solutions possibles:" -ForegroundColor Yellow
Write-Host "1. Si auth-service n'est pas démarré: docker-compose up -d auth-service" -ForegroundColor White
Write-Host "2. Si postgres-auth n'est pas démarré: docker-compose up -d postgres-auth" -ForegroundColor White
Write-Host "3. Si erreur de connexion DB: vérifier les variables d'environnement" -ForegroundColor White
Write-Host "4. Redémarrer tout: .\scripts\restart-all.ps1" -ForegroundColor White

