package com.episecurity.epibrother.service;

import com.episecurity.epibrother.dto.request.CreateUserRequest;
import com.episecurity.epibrother.dto.request.UpdateProfileRequest;
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
    public UserResponse assignManager(Long employeeId, Long managerId) {
        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable"));

        if (employee.getRole() != RoleType.EMPLOYEE) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Seul un salarié peut être affecté à un manager.");
        }

        if (managerId == null) {
            employee.setManager(null);
        } else {
            User manager = userRepository.findById(managerId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Manager introuvable"));
            if (manager.getRole() != RoleType.MANAGER) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Le destinataire doit avoir le rôle MANAGER.");
            }
            employee.setManager(manager);
        }

        return UserResponse.fromEntity(userRepository.save(employee));
    }

    @Transactional
    public UserResponse updateProfile(String username, UpdateProfileRequest request) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable"));

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName().trim());
        }

        if (request.getUsername() != null && !request.getUsername().isBlank()) {
            String newUsername = request.getUsername().trim();
            if (!newUsername.equals(user.getUsername())
                    && userRepository.existsByUsername(newUsername)) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Ce nom d'utilisateur est déjà utilisé.");
            }
            user.setUsername(newUsername);
        }

        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        return UserResponse.fromEntity(userRepository.save(user));
    }

    public List<UserResponse> getColleagues(String username) {
        User current = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable"));

        if (current.getRole() == RoleType.ADMIN) {
            return userRepository.findAll().stream()
                    .filter(user -> !user.getId().equals(current.getId()))
                    .map(UserResponse::fromEntity)
                    .collect(Collectors.toList());
        }

        if (current.getRole() == RoleType.MANAGER) {
            return userRepository.findByManagerId(current.getId()).stream()
                    .map(UserResponse::fromEntity)
                    .collect(Collectors.toList());
        }

        if (current.getManager() == null) {
            return userRepository.findAll().stream()
                    .filter(user -> user.getRole() == RoleType.ADMIN)
                    .map(UserResponse::fromEntity)
                    .collect(Collectors.toList());
        }

        List<User> contacts = userRepository.findAll().stream()
                .filter(user -> user.getRole() == RoleType.ADMIN
                        || user.getId().equals(current.getManager().getId()))
                .collect(Collectors.toList());
        contacts.addAll(userRepository.findByManagerId(current.getManager().getId()).stream()
                .filter(user -> !user.getId().equals(current.getId()))
                .toList());

        return contacts.stream()
                .map(UserResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable avec l'id: " + id);
        }
        userRepository.deleteById(id);
    }
}
