package com.rd.validation.dto;

import java.time.LocalDateTime;

public class ValidationStepResponse {
    private Long idStep;
    private Long idValidation;
    private Long reviewerId;
    private String statut;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public ValidationStepResponse() {
    }

    public ValidationStepResponse(Long idStep, Long idValidation, Long reviewerId, String statut,
                                 LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.idStep = idStep;
        this.idValidation = idValidation;
        this.reviewerId = reviewerId;
        this.statut = statut;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
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

