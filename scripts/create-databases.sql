-- Script SQL pour créer toutes les bases de données et utilisateurs
-- À exécuter en tant que superutilisateur PostgreSQL

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

-- Se connecter à chaque base et accorder les privilèges sur le schéma public
\c auth_db
GRANT ALL ON SCHEMA public TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO auth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO auth_user;

\c project_db
GRANT ALL ON SCHEMA public TO project_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO project_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO project_user;

\c validation_db
GRANT ALL ON SCHEMA public TO validation_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO validation_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO validation_user;

\c finance_db
GRANT ALL ON SCHEMA public TO finance_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO finance_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO finance_user;

-- Vérification
\c auth_db
\dt

\c project_db
\dt

\c validation_db
\dt

\c finance_db
\dt

\q

