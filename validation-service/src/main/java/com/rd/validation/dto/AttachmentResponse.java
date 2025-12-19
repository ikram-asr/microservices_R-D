package com.rd.validation.dto;

import java.time.LocalDateTime;

public class AttachmentResponse {
    private Long idAttachment;
    private Long idStep;
    private String filepath;
    private LocalDateTime createdAt;

    public AttachmentResponse() {
    }

    public AttachmentResponse(Long idAttachment, Long idStep, String filepath, LocalDateTime createdAt) {
        this.idAttachment = idAttachment;
        this.idStep = idStep;
        this.filepath = filepath;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getIdAttachment() {
        return idAttachment;
    }

    public void setIdAttachment(Long idAttachment) {
        this.idAttachment = idAttachment;
    }

    public Long getIdStep() {
        return idStep;
    }

    public void setIdStep(Long idStep) {
        this.idStep = idStep;
    }

    public String getFilepath() {
        return filepath;
    }

    public void setFilepath(String filepath) {
        this.filepath = filepath;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}

