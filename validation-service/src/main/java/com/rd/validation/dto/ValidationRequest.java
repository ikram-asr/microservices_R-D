package com.rd.validation.dto;

import com.rd.validation.model.ValidationStatus;
import jakarta.validation.constraints.NotNull;

public class ValidationRequest {
    @NotNull
    private Long projectId;

    private ValidationStatus status;

    private String comments;

    private Integer validationLevel = 1;

    public Long getProjectId() {
        return projectId;
    }

    public void setProjectId(Long projectId) {
        this.projectId = projectId;
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
}

