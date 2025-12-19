# Guide des Scripts SQL

## Scripts disponibles

### 1. `create-all-databases.sql` ⭐ **RECOMMANDÉ POUR PGADMIN**
Script complet et simple pour pgAdmin. Exécutez section par section :
- **Étape 1** : En tant que postgres (création utilisateurs et bases)
- **Étape 2** : Connecté à `auth_db` (création table users)
- **Étape 3** : Connecté à `project_db` (création tables projects, phases, milestones)
- **Étape 4** : Connecté à `validation_db` (création tables validations, validation_steps, attachments)
- **Étape 5** : Connecté à `finance_db` (création tables teams, budgets, expenses)

### 2. `create-databases-complete.sql`
Version détaillée avec toutes les explications et commentaires.

### 3. `create-databases-pgadmin.sql`
Version alternative avec gestion des erreurs si les objets existent déjà.

### 4. `create-databases.sql`
Version pour psql (ligne de commande) - crée uniquement les bases, pas les tables.

## Instructions pour pgAdmin

### Méthode 1 : Script unique (Recommandé)

1. Ouvrez pgAdmin
2. Connectez-vous en tant que `postgres`
3. Ouvrez l'éditeur de requête (clic droit sur le serveur → Query Tool)
4. Ouvrez le fichier `create-all-databases.sql`
5. **Exécutez l'ÉTAPE 1** (sélectionnez uniquement la partie ÉTAPE 1 et exécutez)
6. Dans pgAdmin, connectez-vous à la base `auth_db` (clic droit → Query Tool)
7. **Exécutez l'ÉTAPE 2** dans cette nouvelle fenêtre
8. Répétez pour `project_db` (ÉTAPE 3), `validation_db` (ÉTAPE 4), `finance_db` (ÉTAPE 5)

### Méthode 2 : Scripts séparés

1. Exécutez `create-databases.sql` pour créer les bases
2. Pour chaque base, exécutez les migrations Flyway ou créez les tables manuellement

## Structure des tables créées

### auth_db
- **users** : id_user, username, email, password, role, enabled, created_at, updated_at

### project_db
- **projects** : id_project, nom, description, statut, created_at, updated_at
- **phases** : id_phase, nom, id_project (FK), created_at, updated_at
- **milestones** : id_milestone, nom, id_phase (FK), created_at, updated_at

### validation_db
- **validations** : id_validation, id_project, nom_test, statut, created_at, updated_at
- **validation_steps** : id_step, id_validation (FK), reviewer_id, statut, created_at, updated_at
- **attachments** : id_attachment, id_step (FK), filepath, created_at

### finance_db
- **teams** : id_team, nom, created_at, updated_at
- **budgets** : id_budget, id_project, montant, created_at, updated_at
- **expenses** : id_expense, id_project, id_team (FK), montant, created_at

## Vérification

Après avoir exécuté tous les scripts, vous pouvez vérifier avec :

```sql
-- Dans chaque base de données
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

## Notes importantes

- Les mots de passe par défaut sont : `auth_password`, `project_password`, etc.
- **Changez-les en production !**
- Les clés étrangères sont configurées avec `ON DELETE CASCADE` où approprié
- Tous les champs `created_at` et `updated_at` sont automatiquement remplis

