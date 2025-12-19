-- ============================================================================
-- SCRIPT COMPLET POUR PGADMIN - CRÉATION BASES DE DONNÉES ET TABLES
-- ============================================================================
-- 
-- MODE D'EMPLOI :
-- 1. Exécutez d'abord la SECTION 1 (en tant que postgres)
-- 2. Puis pour chaque base de données, connectez-vous à cette base dans pgAdmin
--    et exécutez la section correspondante (2, 3, 4 ou 5)
--
-- ============================================================================

-- ============================================================================
-- SECTION 1 : CRÉATION UTILISATEURS ET BASES (Exécuter en tant que postgres)
-- ============================================================================

-- Créer les utilisateurs
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'auth_user') THEN
        CREATE USER auth_user WITH PASSWORD 'auth_password';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'project_user') THEN
        CREATE USER project_user WITH PASSWORD 'project_password';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'validation_user') THEN
        CREATE USER validation_user WITH PASSWORD 'validation_password';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'finance_user') THEN
        CREATE USER finance_user WITH PASSWORD 'finance_password';
    END IF;
END $$;

-- Créer les bases de données
SELECT 'CREATE DATABASE auth_db OWNER auth_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'auth_db')\gexec

SELECT 'CREATE DATABASE project_db OWNER project_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'project_db')\gexec

SELECT 'CREATE DATABASE validation_db OWNER validation_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'validation_db')\gexec

SELECT 'CREATE DATABASE finance_db OWNER finance_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'finance_db')\gexec

-- Accorder les privilèges
GRANT ALL PRIVILEGES ON DATABASE auth_db TO auth_user;
GRANT ALL PRIVILEGES ON DATABASE project_db TO project_user;
GRANT ALL PRIVILEGES ON DATABASE validation_db TO validation_user;
GRANT ALL PRIVILEGES ON DATABASE finance_db TO finance_user;

-- ============================================================================
-- SECTION 2 : AUTH_DB
-- Connectez-vous à 'auth_db' dans pgAdmin et exécutez cette section
-- ============================================================================

-- Accorder les privilèges
GRANT ALL ON SCHEMA public TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO auth_user;

-- Table users
CREATE TABLE IF NOT EXISTS users (
    id_user BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'RESEARCHER',
    enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================================================
-- SECTION 3 : PROJECT_DB
-- Connectez-vous à 'project_db' dans pgAdmin et exécutez cette section
-- ============================================================================

-- Accorder les privilèges
GRANT ALL ON SCHEMA public TO project_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO project_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO project_user;

-- Table projects
CREATE TABLE IF NOT EXISTS projects (
    id_project BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    statut VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table phases
CREATE TABLE IF NOT EXISTS phases (
    id_phase BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    id_project BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_phase_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE
);

-- Table milestones
CREATE TABLE IF NOT EXISTS milestones (
    id_milestone BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    id_phase BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_milestone_phase FOREIGN KEY (id_phase) REFERENCES phases(id_phase) ON DELETE CASCADE
);

-- Index
CREATE INDEX IF NOT EXISTS idx_projects_statut ON projects(statut);
CREATE INDEX IF NOT EXISTS idx_phases_project_id ON phases(id_project);
CREATE INDEX IF NOT EXISTS idx_milestones_phase_id ON milestones(id_phase);

-- ============================================================================
-- SECTION 4 : VALIDATION_DB
-- Connectez-vous à 'validation_db' dans pgAdmin et exécutez cette section
-- ============================================================================

-- Accorder les privilèges
GRANT ALL ON SCHEMA public TO validation_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO validation_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO validation_user;

-- Table validations
CREATE TABLE IF NOT EXISTS validations (
    id_validation BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    nom_test VARCHAR(255) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table validation_steps
CREATE TABLE IF NOT EXISTS validation_steps (
    id_step BIGSERIAL PRIMARY KEY,
    id_validation BIGINT NOT NULL,
    reviewer_id BIGINT NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_step_validation FOREIGN KEY (id_validation) REFERENCES validations(id_validation) ON DELETE CASCADE
);

-- Table attachments
CREATE TABLE IF NOT EXISTS attachments (
    id_attachment BIGSERIAL PRIMARY KEY,
    id_step BIGINT NOT NULL,
    filepath VARCHAR(500) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attachment_step FOREIGN KEY (id_step) REFERENCES validation_steps(id_step) ON DELETE CASCADE
);

-- Index
CREATE INDEX IF NOT EXISTS idx_validations_project_id ON validations(id_project);
CREATE INDEX IF NOT EXISTS idx_validations_statut ON validations(statut);
CREATE INDEX IF NOT EXISTS idx_validation_steps_validation_id ON validation_steps(id_validation);
CREATE INDEX IF NOT EXISTS idx_validation_steps_reviewer_id ON validation_steps(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_attachments_step_id ON attachments(id_step);

-- ============================================================================
-- SECTION 5 : FINANCE_DB
-- Connectez-vous à 'finance_db' dans pgAdmin et exécutez cette section
-- ============================================================================

-- Accorder les privilèges
GRANT ALL ON SCHEMA public TO finance_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO finance_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO finance_user;

-- Table teams
CREATE TABLE IF NOT EXISTS teams (
    id_team BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table budgets
CREATE TABLE IF NOT EXISTS budgets (
    id_budget BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    montant DECIMAL(19,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table expenses
CREATE TABLE IF NOT EXISTS expenses (
    id_expense BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    id_team BIGINT NOT NULL,
    montant DECIMAL(19,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_expense_team FOREIGN KEY (id_team) REFERENCES teams(id_team)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_budgets_project_id ON budgets(id_project);
CREATE INDEX IF NOT EXISTS idx_expenses_project_id ON expenses(id_project);
CREATE INDEX IF NOT EXISTS idx_expenses_team_id ON expenses(id_team);

-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================

