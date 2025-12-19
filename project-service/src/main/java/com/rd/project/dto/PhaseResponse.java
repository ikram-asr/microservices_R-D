package com.rd.project.dto;

import java.time.LocalDateTime;

public class PhaseResponse {
    private Long idPhase;
    private String nom;
    private Long idProject;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public PhaseResponse() {
    }

    public PhaseResponse(Long idPhase, String nom, Long idProject, 
                        LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idPhase = idPhase;
        this.nom = nom;
        this.idProject = idProject;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public Long getIdPhase() {
        return idPhase;
    }

    public void setIdPhase(Long idPhase) {
        this.idPhase = idPhase;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public Long getIdProject() {
        return idProject;
    }

    public void setIdProject(Long idProject) {
        this.idProject = idProject;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}

