# Modèle Conceptuel de Données (MCD)

## Vue d'ensemble

Chaque microservice possède sa propre base de données PostgreSQL pour garantir l'isolation des données.

## 1. Auth-Service - Base de données : `auth_db`

### Table : `users`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| username | VARCHAR(50) | UNIQUE, NOT NULL | Nom d'utilisateur |
| email | VARCHAR(100) | UNIQUE, NOT NULL | Email |
| password | VARCHAR(255) | NOT NULL | Mot de passe hashé (BCrypt) |
| role | VARCHAR(20) | NOT NULL, DEFAULT 'RESEARCHER' | Rôle : ADMIN, RESEARCHER, VALIDATOR, FINANCE |
| enabled | BOOLEAN | NOT NULL, DEFAULT true | Compte actif/inactif |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

**Index :**
- `idx_users_username` sur `username`
- `idx_users_email` sur `email`

**Diagramme :**
```
┌─────────────────┐
│     users       │
├─────────────────┤
│ id (PK)         │
│ username (UK)   │
│ email (UK)      │
│ password        │
│ role            │
│ enabled         │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

## 2. Project-Service - Base de données : `project_db`

### Table : `projects`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| title | VARCHAR(255) | NOT NULL | Titre du projet |
| description | TEXT | NULL | Description détaillée |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'DRAFT' | Statut : DRAFT, SUBMITTED, IN_REVIEW, APPROVED, REJECTED |
| researcher_id | BIGINT | NOT NULL | ID du chercheur (référence vers auth-service) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

**Index :**
- `idx_projects_researcher_id` sur `researcher_id`
- `idx_projects_status` sur `status`

**Diagramme :**
```
┌─────────────────┐
│    projects     │
├─────────────────┤
│ id (PK)         │
│ title           │
│ description     │
│ status          │
│ researcher_id   │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

## 3. Validation-Service - Base de données : `validation_db`

### Table : `validations`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| project_id | BIGINT | NOT NULL | ID du projet (référence vers project-service) |
| validator_id | BIGINT | NOT NULL | ID du validateur (référence vers auth-service) |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'PENDING' | Statut : PENDING, APPROVED, REJECTED, REQUIRES_REVISION |
| comments | TEXT | NULL | Commentaires du validateur |
| validation_level | INTEGER | NOT NULL, DEFAULT 1 | Niveau : 1=Initial, 2=Senior, 3=Final |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

**Index :**
- `idx_validations_project_id` sur `project_id`
- `idx_validations_validator_id` sur `validator_id`
- `idx_validations_status` sur `status`

**Diagramme :**
```
┌─────────────────┐
│   validations   │
├─────────────────┤
│ id (PK)         │
│ project_id      │
│ validator_id    │
│ status          │
│ comments        │
│ validation_level│
│ created_at      │
│ updated_at      │
└─────────────────┘
```

## 4. Finance-Service - Base de données : `finance_db`

### Table : `budgets`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| project_id | BIGINT | NOT NULL | ID du projet (référence vers project-service) |
| allocated_amount | DECIMAL(19,2) | NOT NULL | Montant alloué |
| spent_amount | DECIMAL(19,2) | NOT NULL, DEFAULT 0 | Montant dépensé |
| currency | VARCHAR(10) | NOT NULL, DEFAULT 'EUR' | Devise |
| fiscal_year | INTEGER | NULL | Année fiscale |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

**Index :**
- `idx_budgets_project_id` sur `project_id`

### Table : `expenses`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| project_id | BIGINT | NOT NULL | ID du projet |
| budget_id | BIGINT | NULL | ID du budget (FK vers budgets) |
| amount | DECIMAL(19,2) | NOT NULL | Montant de la dépense |
| description | TEXT | NULL | Description |
| category | VARCHAR(50) | NULL | Catégorie : EQUIPMENT, TRAVEL, PERSONNEL, OTHER |
| currency | VARCHAR(10) | NOT NULL, DEFAULT 'EUR' | Devise |
| expense_date | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de la dépense |
| created_by | BIGINT | NULL | ID utilisateur créateur |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |

**Index :**
- `idx_expenses_project_id` sur `project_id`
- `idx_expenses_budget_id` sur `budget_id`

**Contrainte de clé étrangère :**
- `budget_id` → `budgets.id`

**Diagramme :**
```
┌─────────────────┐         ┌─────────────────┐
│    budgets      │         │    expenses     │
├─────────────────┤         ├─────────────────┤
│ id (PK)         │◄────────│ budget_id (FK)  │
│ project_id      │         │ id (PK)         │
│ allocated_amount│         │ project_id      │
│ spent_amount    │         │ amount          │
│ currency        │         │ description     │
│ fiscal_year     │         │ category        │
│ created_at      │         │ currency        │
│ updated_at      │         │ expense_date    │
└─────────────────┘         │ created_by      │
                            │ created_at      │
                            └─────────────────┘
```

## Relations entre microservices

```
auth_db (users)
    │
    ├─── researcher_id ───► project_db (projects.researcher_id)
    │
    └─── validator_id ────► validation_db (validations.validator_id)
    
project_db (projects)
    │
    ├─── project_id ───────► validation_db (validations.project_id)
    │
    └─── project_id ───────► finance_db (budgets.project_id)
                              finance_db (expenses.project_id)
```

**Note :** Les relations sont logiques (par ID), pas des clés étrangères physiques car chaque service a sa propre base de données.

