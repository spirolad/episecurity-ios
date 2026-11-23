package com.episecurity.epibrother.dto.request;

public class UpdateManagerRequest {
    private Long managerId;

    public UpdateManagerRequest() {
    }

    public UpdateManagerRequest(Long managerId) {
        this.managerId = managerId;
    }

    public Long getManagerId() {
        return managerId;
    }

    public void setManagerId(Long managerId) {
        this.managerId = managerId;
    }
}
