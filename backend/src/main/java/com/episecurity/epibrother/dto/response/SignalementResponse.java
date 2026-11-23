package com.episecurity.epibrother.dto.response;

import com.episecurity.epibrother.model.entity.Signalement;

import java.time.LocalDateTime;

public class SignalementResponse {

    private Long id;
    private Long messageId;
    private String messageContent;
    private UserResponse sender;
    private UserResponse recipient;
    private String reason;
    private String severity;
    private String status;
    private LocalDateTime createdAt;

    public SignalementResponse() {
    }

    public SignalementResponse(Long id, Long messageId, String messageContent, UserResponse sender,
                               UserResponse recipient, String reason, String severity, String status, LocalDateTime createdAt) {
        this.id = id;
        this.messageId = messageId;
        this.messageContent = messageContent;
        this.sender = sender;
        this.recipient = recipient;
        this.reason = reason;
        this.severity = severity;
        this.status = status;
        this.createdAt = createdAt;
    }

    public static SignalementResponse fromEntity(Signalement signalement) {
        if (signalement == null) {
            return null;
        }
        return new SignalementResponse(
                signalement.getId(),
                signalement.getMessage() != null ? signalement.getMessage().getId() : null,
                signalement.getMessage() != null ? signalement.getMessage().getContent() : null,
                signalement.getMessage() != null ? UserResponse.fromEntity(signalement.getMessage().getSender()) : null,
                signalement.getMessage() != null ? UserResponse.fromEntity(signalement.getMessage().getRecipient()) : null,
                signalement.getReason(),
                signalement.getSeverity(),
                signalement.getStatus(),
                signalement.getCreatedAt()
        );
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getMessageId() {
        return messageId;
    }

    public void setMessageId(Long messageId) {
        this.messageId = messageId;
    }

    public String getMessageContent() {
        return messageContent;
    }

    public void setMessageContent(String messageContent) {
        this.messageContent = messageContent;
    }

    public UserResponse getSender() {
        return sender;
    }

    public void setSender(UserResponse sender) {
        this.sender = sender;
    }

    public UserResponse getRecipient() {
        return recipient;
    }

    public void setRecipient(UserResponse recipient) {
        this.recipient = recipient;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
