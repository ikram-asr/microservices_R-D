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

