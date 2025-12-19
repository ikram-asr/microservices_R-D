package com.rd.finance.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ExpenseResponse {
    private Long idExpense;
    private Long idProject;
    private Long idTeam;
    private BigDecimal montant;
    private LocalDateTime createdAt;

    public ExpenseResponse() {
    }

    public ExpenseResponse(Long idExpense, Long idProject, Long idTeam, BigDecimal montant, LocalDateTime createdAt) {
        this.idExpense = idExpense;
        this.idProject = idProject;
        this.idTeam = idTeam;
        this.montant = montant;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getIdExpense() {
        return idExpense;
    }

    public void setIdExpense(Long idExpense) {
        this.idExpense = idExpense;
    }

    public Long getIdProject() {
        return idProject;
    }

    public void setIdProject(Long idProject) {
        this.idProject = idProject;
    }

    public Long getIdTeam() {
        return idTeam;
    }

    public void setIdTeam(Long idTeam) {
        this.idTeam = idTeam;
    }

    public BigDecimal getMontant() {
        return montant;
    }

    public void setMontant(BigDecimal montant) {
        this.montant = montant;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}

