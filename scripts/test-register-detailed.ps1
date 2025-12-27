# Script de test détaillé avec différents formats JSON
Write-Host "=== TEST D'INSCRIPTION DÉTAILLÉ ===" -ForegroundColor Yellow
Write-Host ""

# Test 1: Format JSON standard
Write-Host "1. Test avec format JSON standard:" -ForegroundColor Cyan
$body1 = @{
    username = "testuser"
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

Write-Host "   JSON envoyé:" -ForegroundColor Gray
Write-Host "   $body1" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8081/auth/register" `
        -Method Post `
        -ContentType "application/json; charset=utf-8" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body1)) `
        -ErrorAction Stop
    
    Write-Host "   ✓ Succès!" -ForegroundColor Green
    Write-Host "   Réponse: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Erreur" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "   Code: $statusCode" -ForegroundColor Red
        Write-Host "   Message: $responseBody" -ForegroundColor Red
    } else {
        Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 2: Format JSON avec -Compress
Write-Host "2. Test avec format JSON compressé:" -ForegroundColor Cyan
$body2 = '{"username":"testuser2","email":"test2@example.com","password":"password123"}'
Write-Host "   JSON envoyé: $body2" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8081/auth/register" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body2 `
        -ErrorAction Stop
    
    Write-Host "   ✓ Succès!" -ForegroundColor Green
    Write-Host "   Réponse: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Erreur" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "   Code: $statusCode" -ForegroundColor Red
        Write-Host "   Message: $responseBody" -ForegroundColor Red
    }
}
Write-Host ""

# Test 3: Vérifier les logs après les tests
Write-Host "3. Dernières lignes des logs auth-service:" -ForegroundColor Cyan
docker logs auth-service --tail 30
Write-Host ""

Write-Host "=== FIN DU TEST ===" -ForegroundColor Yellow

