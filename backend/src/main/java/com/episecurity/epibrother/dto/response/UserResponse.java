package com.episecurity.epibrother.dto.response;

import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;

import java.time.LocalDateTime;

public class UserResponse {

    private Long id;
    private String username;
    private RoleType role;
    private String fullName;
    private LocalDateTime createdAt;
    private Long managerId;
    private String managerName;

    public UserResponse() {
    }

    public UserResponse(Long id, String username, RoleType role, String fullName, LocalDateTime createdAt) {
        this.id = id;
        this.username = username;
        this.role = role;
        this.fullName = fullName;
        this.createdAt = createdAt;
    }

    public UserResponse(Long id, String username, RoleType role, String fullName, LocalDateTime createdAt,
                        Long managerId, String managerName) {
        this(id, username, role, fullName, createdAt);
        this.managerId = managerId;
        this.managerName = managerName;
    }

    public static UserResponse fromEntity(User user) {
        if (user == null) {
            return null;
        }
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getRole(),
                user.getFullName(),
                user.getCreatedAt(),
                user.getManager() != null ? user.getManager().getId() : null,
                user.getManager() != null ? user.getManager().getFullName() : null
        );
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public RoleType getRole() {
        return role;
    }

    public void setRole(RoleType role) {
        this.role = role;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Long getManagerId() {
        return managerId;
    }

    public void setManagerId(Long managerId) {
        this.managerId = managerId;
    }

    public String getManagerName() {
        return managerName;
    }

    public void setManagerName(String managerName) {
        this.managerName = managerName;
    }
}
