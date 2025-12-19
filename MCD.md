# Modèle Conceptuel de Données (MCD) - Version Mise à Jour

## Vue d'ensemble

Chaque microservice possède sa propre base de données PostgreSQL pour garantir l'isolation des données.

## 1. Auth-Service - Base de données : `auth_db`

### Table : `users`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_user | BIGSERIAL | PRIMARY KEY | Identifiant unique |
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
│ id_user (PK)    │
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
| id_project | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| nom | VARCHAR(255) | NOT NULL | Nom du projet |
| description | TEXT | NULL | Description détaillée |
| statut | VARCHAR(20) | NOT NULL, DEFAULT 'DRAFT' | Statut : DRAFT, SUBMITTED, IN_REVIEW, APPROVED, REJECTED |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

### Table : `phases`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_phase | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| nom | VARCHAR(255) | NOT NULL | Nom de la phase |
| id_project | BIGINT | NOT NULL, FK → projects.id_project | ID du projet |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

### Table : `milestones`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_milestone | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| nom | VARCHAR(255) | NOT NULL | Nom du milestone |
| id_phase | BIGINT | NOT NULL, FK → phases.id_phase | ID de la phase |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

**Index :**
- `idx_projects_statut` sur `projects.statut`
- `idx_phases_project_id` sur `phases.id_project`
- `idx_milestones_phase_id` sur `milestones.id_phase`

**Diagramme :**
```
┌─────────────────┐
│    projects     │
├─────────────────┤
│ id_project (PK)│
│ nom             │
│ description     │
│ statut          │
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │
         │ 1:N
         │
         ▼
┌─────────────────┐
│     phases      │
├─────────────────┤
│ id_phase (PK)   │
│ nom             │
│ id_project (FK) │
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │
         │ 1:N
         │
         ▼
┌─────────────────┐
│   milestones    │
├─────────────────┤
│ id_milestone(PK)│
│ nom             │
│ id_phase (FK)   │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

## 3. Validation-Service - Base de données : `validation_db`

### Table : `validations`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_validation | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| id_project | BIGINT | NOT NULL | ID du projet (référence logique vers project-service) |
| nom_test | VARCHAR(255) | NOT NULL | Nom du test de validation |
| statut | VARCHAR(20) | NOT NULL, DEFAULT 'PENDING' | Statut : PENDING, APPROVED, REJECTED, REQUIRES_REVISION |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

### Table : `validation_steps`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_step | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| id_validation | BIGINT | NOT NULL, FK → validations.id_validation | ID de la validation |
| reviewer_id | BIGINT | NOT NULL | ID du reviewer (référence logique vers auth-service.users.id_user) |
| statut | VARCHAR(20) | NOT NULL, DEFAULT 'PENDING' | Statut de l'étape |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

### Table : `attachments`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_attachment | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| id_step | BIGINT | NOT NULL, FK → validation_steps.id_step | ID de l'étape de validation |
| filepath | VARCHAR(500) | NOT NULL | Chemin du fichier |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |

**Index :**
- `idx_validations_project_id` sur `validations.id_project`
- `idx_validations_statut` sur `validations.statut`
- `idx_validation_steps_validation_id` sur `validation_steps.id_validation`
- `idx_validation_steps_reviewer_id` sur `validation_steps.reviewer_id`
- `idx_attachments_step_id` sur `attachments.id_step`

**Diagramme :**
```
┌─────────────────┐
│   validations   │
├─────────────────┤
│ id_validation(PK)│
│ id_project      │
│ nom_test        │
│ statut          │
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │
         │ 1:N
         │
         ▼
┌─────────────────┐
│ validation_steps│
├─────────────────┤
│ id_step (PK)    │
│ id_validation(FK)│
│ reviewer_id     │
│ statut          │
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │
         │ 1:N
         │
         ▼
┌─────────────────┐
│   attachments   │
├─────────────────┤
│ id_attachment(PK)│
│ id_step (FK)    │
│ filepath        │
│ created_at      │
└─────────────────┘
```

## 4. Finance-Service - Base de données : `finance_db`

### Table : `teams`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_team | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| nom | VARCHAR(255) | NOT NULL | Nom de l'équipe |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

### Table : `budgets`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_budget | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| id_project | BIGINT | NOT NULL | ID du projet (référence logique vers project-service) |
| montant | DECIMAL(19,2) | NOT NULL | Montant du budget |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de mise à jour |

### Table : `expenses`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| id_expense | BIGSERIAL | PRIMARY KEY | Identifiant unique |
| id_project | BIGINT | NOT NULL | ID du projet (référence logique vers project-service) |
| id_team | BIGINT | NOT NULL, FK → teams.id_team | ID de l'équipe |
| montant | DECIMAL(19,2) | NOT NULL | Montant de la dépense |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date de création |

**Index :**
- `idx_budgets_project_id` sur `budgets.id_project`
- `idx_expenses_project_id` sur `expenses.id_project`
- `idx_expenses_team_id` sur `expenses.id_team`

**Diagramme :**
```
┌─────────────────┐         ┌─────────────────┐
│     teams       │         │     budgets     │
├─────────────────┤         ├─────────────────┤
│ id_team (PK)    │         │ id_budget (PK)  │
│ nom             │         │ id_project      │
│ created_at      │         │ montant         │
│ updated_at      │         │ created_at      │
└────────┬────────┘         │ updated_at      │
         │                  └─────────────────┘
         │ 1:N
         │
         ▼
┌─────────────────┐
│    expenses     │
├─────────────────┤
│ id_expense (PK) │
│ id_project      │
│ id_team (FK)    │
│ montant         │
│ created_at      │
└─────────────────┘
```

## Relations entre microservices

```
auth_db (users.id_user)
    │
    └─── reviewer_id ───► validation_db (validation_steps.reviewer_id)
    
project_db (projects.id_project)
    │
    ├─── id_project ───────► validation_db (validations.id_project)
    │
    ├─── id_project ───────► finance_db (budgets.id_project)
    │
    └─── id_project ───────► finance_db (expenses.id_project)

project_db (phases.id_phase)
    │
    └─── id_phase ────────► project_db (milestones.id_phase)
```

**Note :** Les relations entre microservices sont logiques (par ID), pas des clés étrangères physiques car chaque service a sa propre base de données. Les relations à l'intérieur d'un même service utilisent des clés étrangères physiques.

## Résumé des Relations

### Relations Physiques (FK dans la même base)

1. **project_db :**
   - `phases.id_project` → `projects.id_project`
   - `milestones.id_phase` → `phases.id_phase`

2. **validation_db :**
   - `validation_steps.id_validation` → `validations.id_validation`
   - `attachments.id_step` → `validation_steps.id_step`

3. **finance_db :**
   - `expenses.id_team` → `teams.id_team`

### Relations Logiques (entre microservices)

1. `validation_steps.reviewer_id` → `auth_db.users.id_user`
2. `validations.id_project` → `project_db.projects.id_project`
3. `budgets.id_project` → `project_db.projects.id_project`
4. `expenses.id_project` → `project_db.projects.id_project`
