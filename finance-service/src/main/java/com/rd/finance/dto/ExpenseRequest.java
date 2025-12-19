package com.rd.finance.dto;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class ExpenseRequest {
    @NotNull
    private Long idProject;

    @NotNull
    private Long idTeam;

    @NotNull
    private BigDecimal montant;

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
}

