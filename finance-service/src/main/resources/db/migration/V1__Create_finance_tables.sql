CREATE TABLE IF NOT EXISTS teams (
    id_team BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS budgets (
    id_budget BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    montant DECIMAL(19,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS expenses (
    id_expense BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    id_team BIGINT NOT NULL,
    montant DECIMAL(19,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_team) REFERENCES teams(id_team)
);

CREATE INDEX idx_budgets_project_id ON budgets(id_project);
CREATE INDEX idx_expenses_project_id ON expenses(id_project);
CREATE INDEX idx_expenses_team_id ON expenses(id_team);

