# Script PowerShell de build pour tous les microservices

Write-Host "Building all microservices..." -ForegroundColor Green

# Build Gateway Service
Write-Host "Building Gateway Service..." -ForegroundColor Yellow
Set-Location gateway-service
mvn clean package -DskipTests
Set-Location ..

# Build Auth Service
Write-Host "Building Auth Service..." -ForegroundColor Yellow
Set-Location auth-service
mvn clean package -DskipTests
Set-Location ..

# Build Project Service
Write-Host "Building Project Service..." -ForegroundColor Yellow
Set-Location project-service
mvn clean package -DskipTests
Set-Location ..

# Build Validation Service
Write-Host "Building Validation Service..." -ForegroundColor Yellow
Set-Location validation-service
mvn clean package -DskipTests
Set-Location ..

# Build Finance Service
Write-Host "Building Finance Service..." -ForegroundColor Yellow
Set-Location finance-service
mvn clean package -DskipTests
Set-Location ..

Write-Host "All services built successfully!" -ForegroundColor Green

