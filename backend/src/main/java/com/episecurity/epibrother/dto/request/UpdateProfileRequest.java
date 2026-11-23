package com.episecurity.epibrother.dto.request;

import jakarta.validation.constraints.Size;

public class UpdateProfileRequest {
    @Size(max = 255)
    private String fullName;

    @Size(max = 100)
    private String username;

    private String password;

    public UpdateProfileRequest() {
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
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
}
