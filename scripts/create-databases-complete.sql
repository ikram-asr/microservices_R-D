-- ============================================================================
-- SCRIPT COMPLET DE CRÉATION DES BASES DE DONNÉES ET TABLES
-- Pour PostgreSQL - À exécuter dans pgAdmin
-- ============================================================================
-- 
-- INSTRUCTIONS :
-- 1. Exécutez la SECTION 1 en tant que superutilisateur (postgres)
-- 2. Pour chaque SECTION suivante, connectez-vous à la base correspondante
--    et exécutez la section appropriée
--
-- ============================================================================

-- ============================================================================
-- SECTION 1 : CRÉATION DES UTILISATEURS ET BASES DE DONNÉES
-- Exécuter cette section en tant que superutilisateur (postgres)
-- ============================================================================

-- Supprimer les bases et utilisateurs existants (optionnel - décommenter si nécessaire)
-- DROP DATABASE IF EXISTS auth_db;
-- DROP DATABASE IF EXISTS project_db;
-- DROP DATABASE IF EXISTS validation_db;
-- DROP DATABASE IF EXISTS finance_db;
-- DROP USER IF EXISTS auth_user;
-- DROP USER IF EXISTS project_user;
-- DROP USER IF EXISTS validation_user;
-- DROP USER IF EXISTS finance_user;

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

-- Accorder les privilèges sur les bases de données
GRANT ALL PRIVILEGES ON DATABASE auth_db TO auth_user;
GRANT ALL PRIVILEGES ON DATABASE project_db TO project_user;
GRANT ALL PRIVILEGES ON DATABASE validation_db TO validation_user;
GRANT ALL PRIVILEGES ON DATABASE finance_db TO finance_user;

-- ============================================================================
-- SECTION 2 : BASE DE DONNÉES auth_db
-- Connectez-vous à la base 'auth_db' et exécutez cette section
-- ============================================================================

-- Se connecter à auth_db (dans pgAdmin, sélectionnez auth_db dans le menu déroulant)
-- Puis exécutez :

-- Accorder les privilèges sur le schéma public
GRANT ALL ON SCHEMA public TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO auth_user;

-- Créer la table users
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

-- Créer les index
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================================================
-- SECTION 3 : BASE DE DONNÉES project_db
-- Connectez-vous à la base 'project_db' et exécutez cette section
-- ============================================================================

-- Se connecter à project_db (dans pgAdmin, sélectionnez project_db dans le menu déroulant)
-- Puis exécutez :

-- Accorder les privilèges sur le schéma public
GRANT ALL ON SCHEMA public TO project_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO project_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO project_user;

-- Créer la table projects
CREATE TABLE IF NOT EXISTS projects (
    id_project BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    statut VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Créer la table phases
CREATE TABLE IF NOT EXISTS phases (
    id_phase BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    id_project BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_phase_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE
);

-- Créer la table milestones
CREATE TABLE IF NOT EXISTS milestones (
    id_milestone BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    id_phase BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_milestone_phase FOREIGN KEY (id_phase) REFERENCES phases(id_phase) ON DELETE CASCADE
);

-- Créer les index
CREATE INDEX IF NOT EXISTS idx_projects_statut ON projects(statut);
CREATE INDEX IF NOT EXISTS idx_phases_project_id ON phases(id_project);
CREATE INDEX IF NOT EXISTS idx_milestones_phase_id ON milestones(id_phase);

-- ============================================================================
-- SECTION 4 : BASE DE DONNÉES validation_db
-- Connectez-vous à la base 'validation_db' et exécutez cette section
-- ============================================================================

-- Se connecter à validation_db (dans pgAdmin, sélectionnez validation_db dans le menu déroulant)
-- Puis exécutez :

-- Accorder les privilèges sur le schéma public
GRANT ALL ON SCHEMA public TO validation_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO validation_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO validation_user;

-- Créer la table validations
CREATE TABLE IF NOT EXISTS validations (
    id_validation BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    nom_test VARCHAR(255) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Créer la table validation_steps
CREATE TABLE IF NOT EXISTS validation_steps (
    id_step BIGSERIAL PRIMARY KEY,
    id_validation BIGINT NOT NULL,
    reviewer_id BIGINT NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_step_validation FOREIGN KEY (id_validation) REFERENCES validations(id_validation) ON DELETE CASCADE
);

-- Créer la table attachments
CREATE TABLE IF NOT EXISTS attachments (
    id_attachment BIGSERIAL PRIMARY KEY,
    id_step BIGINT NOT NULL,
    filepath VARCHAR(500) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attachment_step FOREIGN KEY (id_step) REFERENCES validation_steps(id_step) ON DELETE CASCADE
);

-- Créer les index
CREATE INDEX IF NOT EXISTS idx_validations_project_id ON validations(id_project);
CREATE INDEX IF NOT EXISTS idx_validations_statut ON validations(statut);
CREATE INDEX IF NOT EXISTS idx_validation_steps_validation_id ON validation_steps(id_validation);
CREATE INDEX IF NOT EXISTS idx_validation_steps_reviewer_id ON validation_steps(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_attachments_step_id ON attachments(id_step);

-- ============================================================================
-- SECTION 5 : BASE DE DONNÉES finance_db
-- Connectez-vous à la base 'finance_db' et exécutez cette section
-- ============================================================================

-- Se connecter à finance_db (dans pgAdmin, sélectionnez finance_db dans le menu déroulant)
-- Puis exécutez :

-- Accorder les privilèges sur le schéma public
GRANT ALL ON SCHEMA public TO finance_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO finance_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO finance_user;

-- Créer la table teams
CREATE TABLE IF NOT EXISTS teams (
    id_team BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Créer la table budgets
CREATE TABLE IF NOT EXISTS budgets (
    id_budget BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    montant DECIMAL(19,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Créer la table expenses
CREATE TABLE IF NOT EXISTS expenses (
    id_expense BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    id_team BIGINT NOT NULL,
    montant DECIMAL(19,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_expense_team FOREIGN KEY (id_team) REFERENCES teams(id_team)
);

-- Créer les index
CREATE INDEX IF NOT EXISTS idx_budgets_project_id ON budgets(id_project);
CREATE INDEX IF NOT EXISTS idx_expenses_project_id ON expenses(id_project);
CREATE INDEX IF NOT EXISTS idx_expenses_team_id ON expenses(id_team);

-- ============================================================================
-- VÉRIFICATION
-- Vous pouvez exécuter ces requêtes pour vérifier que tout est créé correctement
-- ============================================================================

-- Dans auth_db :
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Dans project_db :
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Dans validation_db :
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Dans finance_db :
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================

