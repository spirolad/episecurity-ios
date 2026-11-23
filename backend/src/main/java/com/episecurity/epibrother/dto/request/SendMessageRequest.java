package com.episecurity.epibrother.dto.request;

import jakarta.validation.constraints.NotBlank;

public class SendMessageRequest {

    private Long senderId;

    private Long recipientId;

    @NotBlank(message = "Le contenu du message ne peut pas être vide")
    private String content;

    private boolean flaggedByAi;
    private String analysisReason;
    private String analysisSeverity;

    public SendMessageRequest() {
    }

    public SendMessageRequest(Long senderId, Long recipientId, String content) {
        this.senderId = senderId;
        this.recipientId = recipientId;
        this.content = content;
    }

    public SendMessageRequest(Long recipientId, String content) {
        this.recipientId = recipientId;
        this.content = content;
    }

    public SendMessageRequest(
            Long senderId,
            Long recipientId,
            String content,
            boolean flaggedByAi,
            String analysisReason,
            String analysisSeverity) {
        this.senderId = senderId;
        this.recipientId = recipientId;
        this.content = content;
        this.flaggedByAi = flaggedByAi;
        this.analysisReason = analysisReason;
        this.analysisSeverity = analysisSeverity;
    }

    public Long getSenderId() {
        return senderId;
    }

    public void setSenderId(Long senderId) {
        this.senderId = senderId;
    }

    public Long getRecipientId() {
        return recipientId;
    }

    public void setRecipientId(Long recipientId) {
        this.recipientId = recipientId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isFlaggedByAi() {
        return flaggedByAi;
    }

    public void setFlaggedByAi(boolean flaggedByAi) {
        this.flaggedByAi = flaggedByAi;
    }

    public String getAnalysisReason() {
        return analysisReason;
    }

    public void setAnalysisReason(String analysisReason) {
        this.analysisReason = analysisReason;
    }

    public String getAnalysisSeverity() {
        return analysisSeverity;
    }

    public void setAnalysisSeverity(String analysisSeverity) {
        this.analysisSeverity = analysisSeverity;
    }
}
