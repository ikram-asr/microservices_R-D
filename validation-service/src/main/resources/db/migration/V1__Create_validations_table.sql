CREATE TABLE IF NOT EXISTS validations (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL,
    validator_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    comments TEXT,
    validation_level INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_validations_project_id ON validations(project_id);
CREATE INDEX idx_validations_validator_id ON validations(validator_id);
CREATE INDEX idx_validations_status ON validations(status);

