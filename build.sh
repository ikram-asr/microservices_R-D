#!/bin/bash

# Script de build pour tous les microservices

echo "Building all microservices..."

# Build Gateway Service
echo "Building Gateway Service..."
cd gateway-service
mvn clean package -DskipTests
cd ..

# Build Auth Service
echo "Building Auth Service..."
cd auth-service
mvn clean package -DskipTests
cd ..

# Build Project Service
echo "Building Project Service..."
cd project-service
mvn clean package -DskipTests
cd ..

# Build Validation Service
echo "Building Validation Service..."
cd validation-service
mvn clean package -DskipTests
cd ..

# Build Finance Service
echo "Building Finance Service..."
cd finance-service
mvn clean package -DskipTests
cd ..

echo "All services built successfully!"

