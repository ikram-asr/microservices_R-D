CREATE TABLE IF NOT EXISTS projects (
    id_project BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    statut VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS phases (
    id_phase BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    id_project BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS milestones (
    id_milestone BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    id_phase BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_phase) REFERENCES phases(id_phase) ON DELETE CASCADE
);

CREATE INDEX idx_projects_statut ON projects(statut);
CREATE INDEX idx_phases_project_id ON phases(id_project);
CREATE INDEX idx_milestones_phase_id ON milestones(id_phase);

