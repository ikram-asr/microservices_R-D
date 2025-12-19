CREATE TABLE IF NOT EXISTS validations (
    id_validation BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL,
    nom_test VARCHAR(255) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS validation_steps (
    id_step BIGSERIAL PRIMARY KEY,
    id_validation BIGINT NOT NULL,
    reviewer_id BIGINT NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_validation) REFERENCES validations(id_validation) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attachments (
    id_attachment BIGSERIAL PRIMARY KEY,
    id_step BIGINT NOT NULL,
    filepath VARCHAR(500) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_step) REFERENCES validation_steps(id_step) ON DELETE CASCADE
);

CREATE INDEX idx_validations_project_id ON validations(id_project);
CREATE INDEX idx_validations_statut ON validations(statut);
CREATE INDEX idx_validation_steps_validation_id ON validation_steps(id_validation);
CREATE INDEX idx_validation_steps_reviewer_id ON validation_steps(reviewer_id);
CREATE INDEX idx_attachments_step_id ON attachments(id_step);

