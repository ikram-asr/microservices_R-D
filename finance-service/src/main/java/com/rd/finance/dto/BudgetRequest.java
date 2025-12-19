package com.rd.finance.dto;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class BudgetRequest {
    @NotNull
    private Long idProject;

    @NotNull
    private BigDecimal montant;

    public Long getIdProject() {
        return idProject;
    }

    public void setIdProject(Long idProject) {
        this.idProject = idProject;
    }

    public BigDecimal getMontant() {
        return montant;
    }

    public void setMontant(BigDecimal montant) {
        this.montant = montant;
    }
}

