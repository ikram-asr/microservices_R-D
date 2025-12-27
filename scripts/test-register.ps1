# Script de test pour l'inscription avec gestion d'erreurs détaillée
Write-Host "=== TEST D'INSCRIPTION ===" -ForegroundColor Yellow
Write-Host ""

# Test 1: Vérifier que auth-service répond
Write-Host "1. Test de santé auth-service:" -ForegroundColor Cyan
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8081/actuator/health" -TimeoutSec 5
    Write-Host "   ✓ auth-service est en ligne" -ForegroundColor Green
} catch {
    Write-Host "   ✗ auth-service ne répond pas: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Vérifier que NGINX répond
Write-Host "2. Test de santé NGINX:" -ForegroundColor Cyan
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8085/health" -TimeoutSec 5
    Write-Host "   ✓ NGINX est en ligne" -ForegroundColor Green
} catch {
    Write-Host "   ✗ NGINX ne répond pas: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Test d'inscription avec gestion d'erreurs
Write-Host "3. Test d'inscription:" -ForegroundColor Cyan
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

Write-Host "   Données envoyées:" -ForegroundColor Gray
Write-Host "   $body" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8085/api/auth/register" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body `
        -ErrorAction Stop
    
    Write-Host "   ✓ Inscription réussie!" -ForegroundColor Green
    Write-Host "   Token: $($response.accessToken.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host "   User ID: $($response.userId)" -ForegroundColor Gray
    Write-Host "   Username: $($response.username)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Erreur lors de l'inscription" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Détails de l'erreur:" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "   Code HTTP: $statusCode" -ForegroundColor Red
        
        # Lire le corps de la réponse d'erreur
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        $reader.Close()
        
        Write-Host "   Message: $responseBody" -ForegroundColor Red
        
        if ($statusCode -eq 400) {
            Write-Host ""
            Write-Host "   Solutions possibles:" -ForegroundColor Yellow
            Write-Host "   - Vérifier que tous les champs sont présents (username, email, password)" -ForegroundColor White
            Write-Host "   - Vérifier que l'email est valide" -ForegroundColor White
            Write-Host "   - Vérifier que le password fait au moins 6 caractères" -ForegroundColor White
            Write-Host "   - Vérifier que le username fait entre 3 et 50 caractères" -ForegroundColor White
            Write-Host "   - Vérifier les logs: docker logs auth-service --tail 50" -ForegroundColor White
        }
    } else {
        Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 4: Vérifier les logs auth-service
Write-Host "4. Dernières lignes des logs auth-service:" -ForegroundColor Cyan
docker logs auth-service --tail 20
Write-Host ""

Write-Host "=== FIN DU TEST ===" -ForegroundColor Yellow
