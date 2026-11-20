package com.episecurity.epibrother.service;

import com.episecurity.epibrother.dto.request.CreateUserRequest;
import com.episecurity.epibrother.dto.request.LoginRequest;
import com.episecurity.epibrother.dto.response.AuthResponse;
import com.episecurity.epibrother.dto.response.UserResponse;
import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import com.episecurity.epibrother.repository.UserRepository;
import com.episecurity.epibrother.security.JwtTokenProvider;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Identifiants invalides"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Identifiants invalides");
        }

        String token = tokenProvider.generateToken(user.getUsername(), user.getId(), user.getRole());
        return new AuthResponse(token, user.getId(), user.getUsername(), user.getFullName(), user.getRole());
    }

    public AuthResponse register(CreateUserRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Le nom d'utilisateur '" + request.getUsername() + "' est déjà pris");
        }

        RoleType role = request.getRole() != null ? request.getRole() : RoleType.EMPLOYEE;
        String rawPassword = (request.getPassword() != null && !request.getPassword().isBlank()) 
                ? request.getPassword() 
                : "password123";
        String encodedPassword = passwordEncoder.encode(rawPassword);

        User user = new User(request.getUsername(), encodedPassword, role, request.getFullName());
        User saved = userRepository.save(user);

        String token = tokenProvider.generateToken(saved.getUsername(), saved.getId(), saved.getRole());
        return new AuthResponse(token, saved.getId(), saved.getUsername(), saved.getFullName(), saved.getRole());
    }

    public UserResponse getCurrentUser(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable: " + username));
        return UserResponse.fromEntity(user);
    }
}
