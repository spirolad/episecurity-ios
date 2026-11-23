package com.episecurity.epibrother.dto.request;

import com.episecurity.epibrother.model.enums.RoleType;
import jakarta.validation.constraints.NotNull;

public class UpdateUserRoleRequest {

    @NotNull(message = "Le rôle est obligatoire (EMPLOYEE, MANAGER, ADMIN)")
    private RoleType role;

    public UpdateUserRoleRequest() {
    }

    public UpdateUserRoleRequest(RoleType role) {
        this.role = role;
    }

    public RoleType getRole() {
        return role;
    }

    public void setRole(RoleType role) {
        this.role = role;
    }
}
