# Script PowerShell pour tester les APIs

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Test des APIs - R&D Microservices" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$token = ""

# Fonction pour faire une requête
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Body = $null,
        [string]$Token = $null
    )
    
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    if ($Token) {
        $headers["Authorization"] = "Bearer $Token"
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -Body $Body
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers
        }
        return $response
    } catch {
        Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# 1. Test d'inscription
Write-Host "1. Test d'inscription..." -ForegroundColor Yellow
$registerBody = @{
    username = "testuser"
    email = "testuser@example.com"
    password = "password123"
} | ConvertTo-Json

$registerResponse = Invoke-ApiRequest -Method "POST" -Url "$baseUrl/api/auth/register" -Body $registerBody

if ($registerResponse) {
    Write-Host "✓ Inscription réussie" -ForegroundColor Green
    $token = $registerResponse.token
    Write-Host "Token obtenu: $($token.Substring(0, 20))..." -ForegroundColor Green
} else {
    Write-Host "✗ Échec de l'inscription" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Test de login
Write-Host "2. Test de login..." -ForegroundColor Yellow
$loginBody = @{
    username = "testuser"
    password = "password123"
} | ConvertTo-Json

$loginResponse = Invoke-ApiRequest -Method "POST" -Url "$baseUrl/api/auth/login" -Body $loginBody

if ($loginResponse) {
    Write-Host "✓ Login réussi" -ForegroundColor Green
    $token = $loginResponse.token
} else {
    Write-Host "✗ Échec du login" -ForegroundColor Red
}

Write-Host ""

# 3. Test de validation du token
Write-Host "3. Test de validation du token..." -ForegroundColor Yellow
$validateResponse = Invoke-ApiRequest -Method "POST" -Url "$baseUrl/api/auth/validate" -Token $token

if ($validateResponse -eq $true) {
    Write-Host "✓ Token valide" -ForegroundColor Green
} else {
    Write-Host "✗ Token invalide" -ForegroundColor Red
}

Write-Host ""

# 4. Test de création de projet
Write-Host "4. Test de création de projet..." -ForegroundColor Yellow
$projectBody = @{
    nom = "Projet Test"
    description = "Description du projet test"
    statut = "DRAFT"
} | ConvertTo-Json

$projectResponse = Invoke-ApiRequest -Method "POST" -Url "$baseUrl/api/projects" -Body $projectBody -Token $token

if ($projectResponse) {
    Write-Host "✓ Projet créé avec ID: $($projectResponse.id)" -ForegroundColor Green
    $projectId = $projectResponse.id
} else {
    Write-Host "✗ Échec de création du projet" -ForegroundColor Red
    $projectId = 1
}

Write-Host ""

# 5. Test de liste des projets
Write-Host "5. Test de liste des projets..." -ForegroundColor Yellow
$projectsResponse = Invoke-ApiRequest -Method "GET" -Url "$baseUrl/api/projects" -Token $token

if ($projectsResponse) {
    Write-Host "✓ Liste des projets obtenue ($($projectsResponse.Count) projets)" -ForegroundColor Green
} else {
    Write-Host "✗ Échec de récupération des projets" -ForegroundColor Red
}

Write-Host ""

# 6. Test de création de validation
Write-Host "6. Test de création de validation..." -ForegroundColor Yellow
$validationBody = @{
    idProject = $projectId
    nomTest = "Test de validation"
    statut = "PENDING"
} | ConvertTo-Json

$validationResponse = Invoke-ApiRequest -Method "POST" -Url "$baseUrl/api/validations" -Body $validationBody -Token $token

if ($validationResponse) {
    Write-Host "✓ Validation créée avec ID: $($validationResponse.id)" -ForegroundColor Green
} else {
    Write-Host "✗ Échec de création de validation" -ForegroundColor Red
}

Write-Host ""

# 7. Test de création de budget
Write-Host "7. Test de création de budget..." -ForegroundColor Yellow
$budgetBody = @{
    idProject = $projectId
    montant = 50000.00
} | ConvertTo-Json

$budgetResponse = Invoke-ApiRequest -Method "POST" -Url "$baseUrl/api/finance/budgets" -Body $budgetBody -Token $token

if ($budgetResponse) {
    Write-Host "✓ Budget créé avec ID: $($budgetResponse.id)" -ForegroundColor Green
} else {
    Write-Host "✗ Échec de création de budget" -ForegroundColor Red
}

Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Tests terminés !" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

