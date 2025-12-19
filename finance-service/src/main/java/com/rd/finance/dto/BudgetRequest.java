package com.rd.finance.dto;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class BudgetRequest {
    @NotNull
    private Long projectId;

    @NotNull
    private BigDecimal allocatedAmount;

    private String currency = "EUR";

    private Integer fiscalYear;

    public Long getProjectId() {
        return projectId;
    }

    public void setProjectId(Long projectId) {
        this.projectId = projectId;
    }

    public BigDecimal getAllocatedAmount() {
        return allocatedAmount;
    }

    public void setAllocatedAmount(BigDecimal allocatedAmount) {
        this.allocatedAmount = allocatedAmount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public Integer getFiscalYear() {
        return fiscalYear;
    }

    public void setFiscalYear(Integer fiscalYear) {
        this.fiscalYear = fiscalYear;
    }
}

