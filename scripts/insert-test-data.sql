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

SELECT id, username, email, role FROM users;

-- ============================================
-- PROJECT_DB - Données de test projets
-- ============================================
\c project_db

INSERT INTO projects (title, description, status, researcher_id) VALUES
('Projet Intelligence Artificielle', 'Recherche sur les algorithmes d''apprentissage automatique et deep learning', 'DRAFT', 2),
('Projet Blockchain', 'Étude des applications blockchain dans le secteur financier', 'SUBMITTED', 2),
('Projet IoT', 'Développement de solutions IoT pour l''industrie 4.0', 'IN_REVIEW', 3),
('Projet Cybersécurité', 'Recherche sur les nouvelles menaces et protections', 'APPROVED', 3)
ON CONFLICT DO NOTHING;

SELECT id, title, status, researcher_id FROM projects;

-- ============================================
-- VALIDATION_DB - Données de test validations
-- ============================================
\c validation_db

INSERT INTO validations (project_id, validator_id, status, comments, validation_level) VALUES
(2, 4, 'PENDING', 'Projet en attente de validation initiale', 1),
(3, 4, 'APPROVED', 'Projet approuvé après révision approfondie', 2),
(4, 4, 'APPROVED', 'Projet validé et approuvé', 3)
ON CONFLICT DO NOTHING;

SELECT id, project_id, validator_id, status, validation_level FROM validations;

-- ============================================
-- FINANCE_DB - Données de test budgets et dépenses
-- ============================================
\c finance_db

INSERT INTO budgets (project_id, allocated_amount, spent_amount, currency, fiscal_year) VALUES
(1, 50000.00, 0.00, 'EUR', 2024),
(2, 75000.00, 15000.00, 'EUR', 2024),
(3, 100000.00, 25000.00, 'EUR', 2024),
(4, 60000.00, 60000.00, 'EUR', 2024)
ON CONFLICT DO NOTHING;

INSERT INTO expenses (project_id, budget_id, amount, description, category, currency, created_by) VALUES
(2, 2, 10000.00, 'Achat équipement de laboratoire', 'EQUIPMENT', 'EUR', 2),
(2, 2, 5000.00, 'Déplacement conférence internationale', 'TRAVEL', 'EUR', 2),
(3, 3, 20000.00, 'Salaires chercheurs', 'PERSONNEL', 'EUR', 3),
(3, 3, 5000.00, 'Matériel de développement', 'EQUIPMENT', 'EUR', 3),
(4, 4, 40000.00, 'Infrastructure cloud', 'OTHER', 'EUR', 3),
(4, 4, 20000.00, 'Formation et certification', 'OTHER', 'EUR', 3)
ON CONFLICT DO NOTHING;

SELECT b.id, b.project_id, b.allocated_amount, b.spent_amount, 
       (b.allocated_amount - b.spent_amount) as remaining_amount
FROM budgets b;

SELECT e.id, e.project_id, e.amount, e.description, e.category 
FROM expenses e;

-- ============================================
-- Requêtes de vérification
-- ============================================

\c auth_db
SELECT 'Users count: ' || COUNT(*) FROM users;

\c project_db
SELECT 'Projects count: ' || COUNT(*) FROM projects;

\c validation_db
SELECT 'Validations count: ' || COUNT(*) FROM validations;

\c finance_db
SELECT 'Budgets count: ' || COUNT(*) FROM budgets;
SELECT 'Expenses count: ' || COUNT(*) FROM expenses;

\q

