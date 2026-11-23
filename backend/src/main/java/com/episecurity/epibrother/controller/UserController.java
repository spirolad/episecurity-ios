package com.episecurity.epibrother.controller;

import com.episecurity.epibrother.dto.request.CreateUserRequest;
import com.episecurity.epibrother.dto.request.UpdateUserRoleRequest;
import com.episecurity.epibrother.dto.request.UpdateManagerRequest;
import com.episecurity.epibrother.dto.request.UpdateProfileRequest;
import com.episecurity.epibrother.dto.response.UserResponse;
import com.episecurity.epibrother.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ResponseEntity<List<UserResponse>> getAllUsers(
            @AuthenticationPrincipal UserDetails userDetails) {
        if (userDetails == null) {
            return ResponseEntity.ok(List.of());
        }
        return ResponseEntity.ok(userService.getColleagues(userDetails.getUsername()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserResponse created = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * Seul l'administrateur peut modifier le rôle d'un utilisateur.
     */
    @PatchMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> updateUserRolePatch(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRoleRequest request) {
        return ResponseEntity.ok(userService.updateUserRole(id, request.getRole()));
    }

    @PutMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> updateUserRolePut(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRoleRequest request) {
        return ResponseEntity.ok(userService.updateUserRole(id, request.getRole()));
    }

    /**
     * Seul l'administrateur peut supprimer un utilisateur.
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/manager")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> updateManager(
            @PathVariable Long id,
            @Valid @RequestBody UpdateManagerRequest request) {
        return ResponseEntity.ok(userService.assignManager(id, request.getManagerId()));
    }

    @PatchMapping("/me")
    public ResponseEntity<UserResponse> updateProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UpdateProfileRequest request) {
        if (userDetails == null) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(userService.updateProfile(userDetails.getUsername(), request));
    }
}
