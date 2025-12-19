package com.rd.validation.dto;

import jakarta.validation.constraints.NotNull;

public class ValidationStepRequest {
    @NotNull
    private Long idValidation;

    @NotNull
    private Long reviewerId;

    private String statut = "PENDING";

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
}

