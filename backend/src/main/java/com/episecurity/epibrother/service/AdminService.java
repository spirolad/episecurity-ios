package com.episecurity.epibrother.service;

import com.episecurity.epibrother.dto.response.UserResponse;
import com.episecurity.epibrother.model.enums.RoleType;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminService {

    private final UserService userService;

    public AdminService(UserService userService) {
        this.userService = userService;
    }

    public List<UserResponse> getAllUsers() {
        return userService.getAllUsers();
    }

    public UserResponse updateUserRole(Long userId, RoleType role) {
        return userService.updateUserRole(userId, role);
    }

    public void deleteUser(Long userId) {
        userService.deleteUser(userId);
    }

    public UserResponse assignEmployeeToManager(Long employeeId, Long managerId) {
        return userService.assignManager(employeeId, managerId);
    }
}
