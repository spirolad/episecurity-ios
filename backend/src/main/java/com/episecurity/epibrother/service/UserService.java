package com.episecurity.epibrother.service;

import com.episecurity.epibrother.dto.request.CreateUserRequest;
import com.episecurity.epibrother.dto.response.UserResponse;
import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import com.episecurity.epibrother.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(UserResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public UserResponse getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable avec l'id: " + id));
        return UserResponse.fromEntity(user);
    }

    public UserResponse createUser(CreateUserRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Le nom d'utilisateur '" + request.getUsername() + "' existe déjà");
        }
        String rawPassword = (request.getPassword() != null && !request.getPassword().isBlank()) 
                ? request.getPassword() 
                : "password123";
        String encodedPassword = passwordEncoder.encode(rawPassword);

        User user = new User(request.getUsername(), encodedPassword, request.getRole(), request.getFullName());
        User saved = userRepository.save(user);
        return UserResponse.fromEntity(saved);
    }

    @Transactional
    public UserResponse updateUserRole(Long id, RoleType newRole) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable avec l'id: " + id));
        user.setRole(newRole);
        User updated = userRepository.save(user);
        return UserResponse.fromEntity(updated);
    }

    @Transactional
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable avec l'id: " + id);
        }
        userRepository.deleteById(id);
    }
}
