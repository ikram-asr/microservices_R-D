# Configuration et Tests de la Base de Données PostgreSQL

## Prérequis

- PostgreSQL 14+ installé
- Ou Docker avec PostgreSQL
- Accès en ligne de commande (psql ou pgAdmin)

## Option 1 : Configuration avec Docker Compose (Recommandé)

Les bases de données sont automatiquement créées lors du démarrage de Docker Compose.

```bash
# Démarrer uniquement les bases de données
docker-compose up -d postgres-auth postgres-project postgres-validation postgres-finance

# Vérifier que les bases sont prêtes
docker-compose ps
```

## Option 2 : Configuration PostgreSQL Manuelle

### Étape 1 : Créer les bases de données

Connectez-vous à PostgreSQL en tant que superutilisateur :

```bash
psql -U postgres
```

Puis exécutez les commandes suivantes :

```sql
-- Créer les utilisateurs
CREATE USER auth_user WITH PASSWORD 'auth_password';
CREATE USER project_user WITH PASSWORD 'project_password';
CREATE USER validation_user WITH PASSWORD 'validation_password';
CREATE USER finance_user WITH PASSWORD 'finance_password';

-- Créer les bases de données
CREATE DATABASE auth_db OWNER auth_user;
CREATE DATABASE project_db OWNER project_user;
CREATE DATABASE validation_db OWNER validation_user;
CREATE DATABASE finance_db OWNER finance_user;

-- Accorder les privilèges
GRANT ALL PRIVILEGES ON DATABASE auth_db TO auth_user;
GRANT ALL PRIVILEGES ON DATABASE project_db TO project_user;
GRANT ALL PRIVILEGES ON DATABASE validation_db TO validation_user;
GRANT ALL PRIVILEGES ON DATABASE finance_db TO finance_user;

-- Se connecter à chaque base et accorder les privilèges sur le schéma public
\c auth_db
GRANT ALL ON SCHEMA public TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO auth_user;

\c project_db
GRANT ALL ON SCHEMA public TO project_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO project_user;

\c validation_db
GRANT ALL ON SCHEMA public TO validation_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO validation_user;

\c finance_db
GRANT ALL ON SCHEMA public TO finance_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO finance_user;

\q
```

### Étape 2 : Vérifier la création

```bash
# Lister les bases de données
psql -U postgres -c "\l"

# Vérifier chaque base
psql -U auth_user -d auth_db -c "\dt"
psql -U project_user -d project_db -c "\dt"
psql -U validation_user -d validation_db -c "\dt"
psql -U finance_user -d finance_db -c "\dt"
```

## Étape 3 : Exécuter les migrations Flyway

Les migrations Flyway sont automatiquement exécutées au démarrage de chaque service Spring Boot.

**Si vous voulez les exécuter manuellement :**

### Pour auth-service

```bash
# Se connecter à la base auth_db
psql -U auth_user -d auth_db

# Exécuter le script de migration
\i auth-service/src/main/resources/db/migration/V1__Create_users_table.sql
```

Ou copier le contenu du fichier et l'exécuter dans psql.

## Scripts SQL de Création Manuelle

### Script complet pour auth_db

```sql
-- Se connecter à auth_db
\c auth_db

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'RESEARCHER',
    enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
```

### Script complet pour project_db

```sql
\c project_db

CREATE TABLE IF NOT EXISTS projects (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    researcher_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_projects_researcher_id ON projects(researcher_id);
CREATE INDEX idx_projects_status ON projects(status);
```

### Script complet pour validation_db

```sql
\c validation_db

CREATE TABLE IF NOT EXISTS validations (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL,
    validator_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    comments TEXT,
    validation_level INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_validations_project_id ON validations(project_id);
CREATE INDEX idx_validations_validator_id ON validations(validator_id);
CREATE INDEX idx_validations_status ON validations(status);
```

### Script complet pour finance_db

```sql
\c finance_db

CREATE TABLE IF NOT EXISTS budgets (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL,
    allocated_amount DECIMAL(19,2) NOT NULL,
    spent_amount DECIMAL(19,2) NOT NULL DEFAULT 0,
    currency VARCHAR(10) NOT NULL DEFAULT 'EUR',
    fiscal_year INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS expenses (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL,
    budget_id BIGINT,
    amount DECIMAL(19,2) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    currency VARCHAR(10) NOT NULL DEFAULT 'EUR',
    expense_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (budget_id) REFERENCES budgets(id)
);

CREATE INDEX idx_budgets_project_id ON budgets(project_id);
CREATE INDEX idx_expenses_project_id ON expenses(project_id);
CREATE INDEX idx_expenses_budget_id ON expenses(budget_id);
```

## Tests de la Base de Données

### Test 1 : Vérifier les tables créées

```bash
# Pour chaque base de données
psql -U auth_user -d auth_db -c "\dt"
psql -U project_user -d project_db -c "\dt"
psql -U validation_user -d validation_db -c "\dt"
psql -U finance_user -d finance_db -c "\dt"
```

### Test 2 : Insérer des données de test

#### Dans auth_db

```sql
psql -U auth_user -d auth_db

INSERT INTO users (username, email, password, role) VALUES
('admin', 'admin@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN'),
('researcher1', 'researcher1@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'RESEARCHER'),
('validator1', 'validator1@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'VALIDATOR');

-- Vérifier
SELECT id, username, email, role FROM users;
```

**Note :** Le mot de passe hashé correspond à "password123" (utilisé pour les tests).

#### Dans project_db

```sql
psql -U project_user -d project_db

INSERT INTO projects (title, description, status, researcher_id) VALUES
('Projet IA', 'Projet sur l''intelligence artificielle', 'DRAFT', 2),
('Projet Blockchain', 'Recherche sur la blockchain', 'SUBMITTED', 2);

SELECT * FROM projects;
```

#### Dans validation_db

```sql
psql -U validation_user -d validation_db

INSERT INTO validations (project_id, validator_id, status, comments, validation_level) VALUES
(1, 3, 'PENDING', 'En attente de validation', 1);

SELECT * FROM validations;
```

#### Dans finance_db

```sql
psql -U finance_user -d finance_db

INSERT INTO budgets (project_id, allocated_amount, currency, fiscal_year) VALUES
(1, 50000.00, 'EUR', 2024),
(2, 75000.00, 'EUR', 2024);

INSERT INTO expenses (project_id, budget_id, amount, description, category) VALUES
(1, 1, 5000.00, 'Achat équipement', 'EQUIPMENT'),
(1, 1, 2000.00, 'Déplacement conférence', 'TRAVEL');

SELECT * FROM budgets;
SELECT * FROM expenses;
```

### Test 3 : Vérifier les relations logiques

```sql
-- Dans project_db : Vérifier les projets avec researcher_id = 2
SELECT * FROM projects WHERE researcher_id = 2;

-- Dans validation_db : Vérifier les validations pour project_id = 1
SELECT * FROM validations WHERE project_id = 1;

-- Dans finance_db : Vérifier le budget et les dépenses pour project_id = 1
SELECT b.*, SUM(e.amount) as total_expenses
FROM budgets b
LEFT JOIN expenses e ON b.id = e.budget_id
WHERE b.project_id = 1
GROUP BY b.id;
```

## Nettoyage des Données de Test

```sql
-- Supprimer les données de test (dans l'ordre inverse des dépendances)

-- finance_db
DELETE FROM expenses;
DELETE FROM budgets;

-- validation_db
DELETE FROM validations;

-- project_db
DELETE FROM projects;

-- auth_db
DELETE FROM users;
```

## Vérification de l'Intégrité

### Script de vérification complète

```bash
#!/bin/bash

echo "=== Vérification des bases de données ==="

echo "1. Vérification auth_db..."
psql -U auth_user -d auth_db -c "SELECT COUNT(*) as user_count FROM users;"

echo "2. Vérification project_db..."
psql -U project_user -d project_db -c "SELECT COUNT(*) as project_count FROM projects;"

echo "3. Vérification validation_db..."
psql -U validation_user -d validation_db -c "SELECT COUNT(*) as validation_count FROM validations;"

echo "4. Vérification finance_db..."
psql -U finance_user -d finance_db -c "SELECT COUNT(*) as budget_count FROM budgets;"
psql -U finance_user -d finance_db -c "SELECT COUNT(*) as expense_count FROM expenses;"

echo "=== Vérification terminée ==="
```

## Connexion depuis les Services Spring Boot

Les services Spring Boot se connectent automatiquement aux bases de données via les variables d'environnement :

- `SPRING_DATASOURCE_URL` : URL de connexion JDBC
- `SPRING_DATASOURCE_USERNAME` : Nom d'utilisateur
- `SPRING_DATASOURCE_PASSWORD` : Mot de passe

Exemple pour auth-service :
```
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/auth_db
SPRING_DATASOURCE_USERNAME=auth_user
SPRING_DATASOURCE_PASSWORD=auth_password
```

## Ports par Défaut (Docker Compose)

- postgres-auth : 5433 (host) → 5432 (container)
- postgres-project : 5434 (host) → 5432 (container)
- postgres-validation : 5435 (host) → 5432 (container)
- postgres-finance : 5436 (host) → 5432 (container)

Pour se connecter depuis l'extérieur du container :
```bash
psql -h localhost -p 5433 -U auth_user -d auth_db
```

