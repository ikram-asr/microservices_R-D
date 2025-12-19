package com.rd.validation.dto;

import com.rd.validation.model.ValidationStatus;
import java.time.LocalDateTime;

public class ValidationResponse {
    private Long id;
    private Long projectId;
    private Long validatorId;
    private ValidationStatus status;
    private String comments;
    private Integer validationLevel;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public ValidationResponse() {
    }

    public ValidationResponse(Long id, Long projectId, Long validatorId, ValidationStatus status,
                             String comments, Integer validationLevel, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.projectId = projectId;
        this.validatorId = validatorId;
        this.status = status;
        this.comments = comments;
        this.validationLevel = validationLevel;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getProjectId() {
        return projectId;
    }

    public void setProjectId(Long projectId) {
        this.projectId = projectId;
    }

    public Long getValidatorId() {
        return validatorId;
    }

    public void setValidatorId(Long validatorId) {
        this.validatorId = validatorId;
    }

    public ValidationStatus getStatus() {
        return status;
    }

    public void setStatus(ValidationStatus status) {
        this.status = status;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public Integer getValidationLevel() {
        return validationLevel;
    }

    public void setValidationLevel(Integer validationLevel) {
        this.validationLevel = validationLevel;
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

