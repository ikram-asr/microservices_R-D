# Script PowerShell de démarrage rapide pour tester l'application
# Usage: .\quick-start.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Démarrage Rapide - Microservices R&D" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$BASE_URL = "http://localhost:8080"

# Test 1: Health Check
Write-Host "1. Test Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/actuator/health" -Method Get
    Write-Host "✓ Gateway est accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Gateway non accessible" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Register/Login
Write-Host "2. Test Authentification..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$registerBody = @{
    username = "testuser$timestamp"
    email = "test$timestamp@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$BASE_URL/api/auth/register" `
        -Method Post -Body $registerBody -ContentType "application/json"
    $TOKEN = $registerResponse.accessToken
    $USER_ID = $registerResponse.userId
    Write-Host "✓ Inscription réussie (User ID: $USER_ID)" -ForegroundColor Green
} catch {
    Write-Host "⚠ Tentative de connexion avec utilisateur existant..." -ForegroundColor Yellow
    $loginBody = @{
        username = "researcher1"
        password = "password123"
    } | ConvertTo-Json
    
    try {
        $loginResponse = Invoke-RestMethod -Uri "$BASE_URL/api/auth/login" `
            -Method Post -Body $loginBody -ContentType "application/json"
        $TOKEN = $loginResponse.accessToken
        Write-Host "✓ Connexion réussie" -ForegroundColor Green
    } catch {
        Write-Host "✗ Échec de l'authentification" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Test 3: Créer un projet
Write-Host "3. Test Création Projet..." -ForegroundColor Yellow
$projectBody = @{
    nom = "Projet Test"
    description = "Description du projet test"
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $TOKEN"
    "Content-Type" = "application/json"
}

try {
    $projectResponse = Invoke-RestMethod -Uri "$BASE_URL/api/projects" `
        -Method Post -Body $projectBody -Headers $headers
    $PROJECT_ID = $projectResponse.idProject
    Write-Host "✓ Projet créé (ID: $PROJECT_ID)" -ForegroundColor Green
} catch {
    Write-Host "✗ Échec de la création du projet" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}
Write-Host ""

# Test 4: Lister les projets
Write-Host "4. Test Liste Projets..." -ForegroundColor Yellow
try {
    $projects = Invoke-RestMethod -Uri "$BASE_URL/api/projects" `
        -Method Get -Headers $headers
    Write-Host "✓ Liste des projets récupérée ($($projects.Count) projets)" -ForegroundColor Green
} catch {
    Write-Host "✗ Échec de la récupération des projets" -ForegroundColor Red
}
Write-Host ""

# Test 5: Créer un budget
Write-Host "5. Test Création Budget..." -ForegroundColor Yellow
$budgetBody = @{
    idProject = $PROJECT_ID
    montant = 50000.00
} | ConvertTo-Json

try {
    $budgetResponse = Invoke-RestMethod -Uri "$BASE_URL/api/finance/budgets" `
        -Method Post -Body $budgetBody -Headers $headers
    $BUDGET_ID = $budgetResponse.idBudget
    Write-Host "✓ Budget créé (ID: $BUDGET_ID)" -ForegroundColor Green
} catch {
    Write-Host "⚠ Échec de la création du budget" -ForegroundColor Yellow
}
Write-Host ""

# Test 6: Créer une équipe
Write-Host "6. Test Création Équipe..." -ForegroundColor Yellow
$teamBody = @{
    nom = "Équipe Test"
} | ConvertTo-Json

try {
    $teamResponse = Invoke-RestMethod -Uri "$BASE_URL/api/finance/teams" `
        -Method Post -Body $teamBody -Headers $headers
    $TEAM_ID = $teamResponse.idTeam
    Write-Host "✓ Équipe créée (ID: $TEAM_ID)" -ForegroundColor Green
    
    # Test 7: Créer une dépense
    Write-Host "7. Test Création Dépense..." -ForegroundColor Yellow
    $expenseBody = @{
        idProject = $PROJECT_ID
        idTeam = $TEAM_ID
        montant = 5000.00
    } | ConvertTo-Json
    
    try {
        $expenseResponse = Invoke-RestMethod -Uri "$BASE_URL/api/finance/expenses" `
            -Method Post -Body $expenseBody -Headers $headers
        Write-Host "✓ Dépense créée" -ForegroundColor Green
    } catch {
        Write-Host "✗ Échec de la création de la dépense" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠ Échec de la création de l'équipe" -ForegroundColor Yellow
}
Write-Host ""

# Test 8: Créer une validation
Write-Host "8. Test Création Validation..." -ForegroundColor Yellow
$validationBody = @{
    idProject = $PROJECT_ID
    nomTest = "Test Intégration"
    statut = "PENDING"
} | ConvertTo-Json

try {
    $validationResponse = Invoke-RestMethod -Uri "$BASE_URL/api/validations" `
        -Method Post -Body $validationBody -Headers $headers
    Write-Host "✓ Validation créée" -ForegroundColor Green
} catch {
    Write-Host "⚠ Échec de la création de la validation" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Tous les tests sont terminés" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Résumé :"
Write-Host "- Token JWT : $TOKEN"
Write-Host "- Projet ID : $PROJECT_ID"
Write-Host ""
Write-Host "Vous pouvez maintenant tester manuellement les autres endpoints !" -ForegroundColor Yellow

