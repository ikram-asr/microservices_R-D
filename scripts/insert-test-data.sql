-- Script SQL pour insérer des données de test
-- À exécuter après le démarrage des services (les migrations Flyway créent les tables)

-- ============================================
-- AUTH_DB - Données de test utilisateurs
-- ============================================
\c auth_db

-- Mot de passe hashé pour "password123" (BCrypt)
-- Vous pouvez générer un nouveau hash avec : BCryptPasswordEncoder dans Spring Boot
INSERT INTO users (username, email, password, role, enabled) VALUES
('admin', 'admin@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', true),
('researcher1', 'researcher1@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'RESEARCHER', true),
('researcher2', 'researcher2@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'RESEARCHER', true),
('validator1', 'validator1@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'VALIDATOR', true),
('finance1', 'finance1@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'FINANCE', true)
ON CONFLICT (username) DO NOTHING;

SELECT id_user, username, email, role FROM users;

-- ============================================
-- PROJECT_DB - Données de test projets, phases, milestones
-- ============================================
\c project_db

INSERT INTO projects (nom, description, statut) VALUES
('Projet Intelligence Artificielle', 'Recherche sur les algorithmes d''apprentissage automatique et deep learning', 'DRAFT'),
('Projet Blockchain', 'Étude des applications blockchain dans le secteur financier', 'SUBMITTED'),
('Projet IoT', 'Développement de solutions IoT pour l''industrie 4.0', 'IN_REVIEW'),
('Projet Cybersécurité', 'Recherche sur les nouvelles menaces et protections', 'APPROVED')
ON CONFLICT DO NOTHING;

INSERT INTO phases (nom, id_project) VALUES
('Phase 1: Analyse', 1),
('Phase 2: Développement', 1),
('Phase 3: Tests', 1),
('Phase 1: Conception', 2),
('Phase 2: Implémentation', 2)
ON CONFLICT DO NOTHING;

INSERT INTO milestones (nom, id_phase) VALUES
('Milestone 1.1: Analyse terminée', 1),
('Milestone 1.2: Documentation complète', 1),
('Milestone 2.1: Prototype fonctionnel', 2),
('Milestone 2.2: Tests unitaires', 2)
ON CONFLICT DO NOTHING;

SELECT id_project, nom, statut FROM projects;
SELECT id_phase, nom, id_project FROM phases;
SELECT id_milestone, nom, id_phase FROM milestones;

-- ============================================
-- VALIDATION_DB - Données de test validations
-- ============================================
\c validation_db

INSERT INTO validations (id_project, nom_test, statut) VALUES
(1, 'Test de performance', 'PENDING'),
(2, 'Test de sécurité', 'APPROVED'),
(3, 'Test d''intégration', 'PENDING'),
(4, 'Test de validation finale', 'APPROVED')
ON CONFLICT DO NOTHING;

INSERT INTO validation_steps (id_validation, reviewer_id, statut) VALUES
(1, 4, 'PENDING'),
(2, 4, 'APPROVED'),
(3, 4, 'PENDING'),
(4, 4, 'APPROVED')
ON CONFLICT DO NOTHING;

INSERT INTO attachments (id_step, filepath) VALUES
(1, '/uploads/validation1/test_report.pdf'),
(2, '/uploads/validation2/security_audit.pdf'),
(3, '/uploads/validation3/integration_test.pdf'),
(4, '/uploads/validation4/final_report.pdf')
ON CONFLICT DO NOTHING;

SELECT id_validation, id_project, nom_test, statut FROM validations;
SELECT id_step, id_validation, reviewer_id, statut FROM validation_steps;
SELECT id_attachment, id_step, filepath FROM attachments;

-- ============================================
-- FINANCE_DB - Données de test teams, budgets et dépenses
-- ============================================
\c finance_db

INSERT INTO teams (nom) VALUES
('Équipe Développement'),
('Équipe Recherche'),
('Équipe Qualité'),
('Équipe Infrastructure')
ON CONFLICT DO NOTHING;

INSERT INTO budgets (id_project, montant) VALUES
(1, 50000.00),
(2, 75000.00),
(3, 100000.00),
(4, 60000.00)
ON CONFLICT DO NOTHING;

INSERT INTO expenses (id_project, id_team, montant) VALUES
(1, 1, 10000.00),
(1, 2, 5000.00),
(2, 1, 20000.00),
(2, 3, 5000.00),
(3, 2, 15000.00),
(3, 4, 10000.00),
(4, 1, 30000.00),
(4, 3, 30000.00)
ON CONFLICT DO NOTHING;

SELECT id_team, nom FROM teams;
SELECT id_budget, id_project, montant FROM budgets;
SELECT id_expense, id_project, id_team, montant FROM expenses;

-- ============================================
-- Requêtes de vérification
-- ============================================

\c auth_db
SELECT 'Users count: ' || COUNT(*) FROM users;

\c project_db
SELECT 'Projects count: ' || COUNT(*) FROM projects;
SELECT 'Phases count: ' || COUNT(*) FROM phases;
SELECT 'Milestones count: ' || COUNT(*) FROM milestones;

\c validation_db
SELECT 'Validations count: ' || COUNT(*) FROM validations;
SELECT 'Validation steps count: ' || COUNT(*) FROM validation_steps;
SELECT 'Attachments count: ' || COUNT(*) FROM attachments;

\c finance_db
SELECT 'Teams count: ' || COUNT(*) FROM teams;
SELECT 'Budgets count: ' || COUNT(*) FROM budgets;
SELECT 'Expenses count: ' || COUNT(*) FROM expenses;

\q
