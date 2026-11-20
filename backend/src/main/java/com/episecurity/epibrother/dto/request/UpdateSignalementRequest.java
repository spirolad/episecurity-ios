package com.episecurity.epibrother.dto.request;

import jakarta.validation.constraints.NotBlank;

public class UpdateSignalementRequest {

    @NotBlank(message = "Le nouveau statut est obligatoire (ex: REVIEWED, DISMISSED)")
    private String status;

    public UpdateSignalementRequest() {
    }

    public UpdateSignalementRequest(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
