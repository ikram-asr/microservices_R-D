package com.rd.project.dto;

import java.time.LocalDateTime;

public class MilestoneResponse {
    private Long idMilestone;
    private String nom;
    private Long idPhase;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public MilestoneResponse() {
    }

    public MilestoneResponse(Long idMilestone, String nom, Long idPhase,
                            LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idMilestone = idMilestone;
        this.nom = nom;
        this.idPhase = idPhase;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public Long getIdMilestone() {
        return idMilestone;
    }

    public void setIdMilestone(Long idMilestone) {
        this.idMilestone = idMilestone;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public Long getIdPhase() {
        return idPhase;
    }

    public void setIdPhase(Long idPhase) {
        this.idPhase = idPhase;
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

