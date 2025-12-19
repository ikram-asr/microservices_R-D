package com.rd.finance.dto;

import jakarta.validation.constraints.NotBlank;

public class TeamRequest {
    @NotBlank
    private String nom;

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }
}

