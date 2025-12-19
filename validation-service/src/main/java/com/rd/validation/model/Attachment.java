package com.rd.validation.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "attachments")
public class Attachment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_attachment")
    private Long idAttachment;

    @Column(name = "id_step")
    private Long idStep;

    @Column(name = "filepath")
    private String filepath;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
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

