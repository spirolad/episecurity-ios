package com.episecurity.epibrother.dto.request;

import jakarta.validation.constraints.NotBlank;

public class SendMessageRequest {

    private Long senderId;

    private Long recipientId;

    @NotBlank(message = "Le contenu du message ne peut pas être vide")
    private String content;

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
}
