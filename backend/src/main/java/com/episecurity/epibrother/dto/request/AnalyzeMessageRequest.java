package com.episecurity.epibrother.dto.request;

import jakarta.validation.constraints.NotBlank;

public class AnalyzeMessageRequest {

    @NotBlank(message = "Le contenu du message ne peut pas être vide")
    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}