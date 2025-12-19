package com.rd.validation.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "validation_steps")
public class ValidationStep {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_step")
    private Long idStep;

    @Column(name = "id_validation")
    private Long idValidation;

    @Column(name = "reviewer_id")
    private Long reviewerId;

    @Column(name = "statut")
    private String statut = "PENDING";

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getIdStep() {
        return idStep;
    }

    public void setIdStep(Long idStep) {
        this.idStep = idStep;
    }

    public Long getIdValidation() {
        return idValidation;
    }

    public void setIdValidation(Long idValidation) {
        this.idValidation = idValidation;
    }

    public Long getReviewerId() {
        return reviewerId;
    }

    public void setReviewerId(Long reviewerId) {
        this.reviewerId = reviewerId;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
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

