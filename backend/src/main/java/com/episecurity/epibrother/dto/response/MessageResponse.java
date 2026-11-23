package com.episecurity.epibrother.dto.response;

import com.episecurity.epibrother.model.entity.Message;

import java.time.LocalDateTime;

public class MessageResponse {

    private Long id;
    private UserResponse sender;
    private UserResponse recipient;
    private String content;
    private boolean flaggedByAi;
    private LocalDateTime createdAt;

    public MessageResponse() {
    }

    public MessageResponse(Long id, UserResponse sender, UserResponse recipient, String content, boolean flaggedByAi, LocalDateTime createdAt) {
        this.id = id;
        this.sender = sender;
        this.recipient = recipient;
        this.content = content;
        this.flaggedByAi = flaggedByAi;
        this.createdAt = createdAt;
    }

    public static MessageResponse fromEntity(Message message, boolean flaggedByAi) {
        if (message == null) {
            return null;
        }
        return new MessageResponse(
                message.getId(),
                UserResponse.fromEntity(message.getSender()),
                UserResponse.fromEntity(message.getRecipient()),
                message.getContent(),
                flaggedByAi,
                message.getCreatedAt()
        );
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
