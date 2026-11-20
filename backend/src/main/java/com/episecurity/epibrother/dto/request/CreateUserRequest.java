package com.episecurity.epibrother.dto.request;

import com.episecurity.epibrother.model.enums.RoleType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CreateUserRequest {

    @NotBlank(message = "Le nom d'utilisateur est obligatoire")
    private String username;

    private String password;

    @NotNull(message = "Le rôle est obligatoire (EMPLOYEE, MANAGER, ADMIN)")
    private RoleType role;

    @NotBlank(message = "Le nom complet est obligatoire")
    private String fullName;

    public CreateUserRequest() {
    }

    public CreateUserRequest(String username, RoleType role, String fullName) {
        this.username = username;
        this.role = role;
        this.fullName = fullName;
    }

    public CreateUserRequest(String username, String password, RoleType role, String fullName) {
        this.username = username;
        this.password = password;
        this.role = role;
        this.fullName = fullName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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
}
