package com.episecurity.epibrother.service;

import com.episecurity.epibrother.dto.request.CreateUserRequest;
import com.episecurity.epibrother.dto.request.LoginRequest;
import com.episecurity.epibrother.dto.response.AuthResponse;
import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import com.episecurity.epibrother.repository.UserRepository;
import com.episecurity.epibrother.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class AuthServiceTest {

    private UserRepository userRepository;
    private PasswordEncoder passwordEncoder;
    private JwtTokenProvider tokenProvider;
    private AuthService authService;

    private static final String TEST_CREDENTIAL = "mock_passphrase_for_testing_only";

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        passwordEncoder = new BCryptPasswordEncoder();
        tokenProvider = new JwtTokenProvider("mockTestingSigningKeyForUnitTestsOnlyDoNotUseInProd2026!", 3600000);
        authService = new AuthService(userRepository, passwordEncoder, tokenProvider);
    }

    @Test
    void testLogin_Success() {
        String encodedHash = passwordEncoder.encode(TEST_CREDENTIAL);
        User user = new User("test_alice", encodedHash, RoleType.EMPLOYEE, "Alice Martin");
        user.setId(1L);

        when(userRepository.findByUsername("test_alice")).thenReturn(Optional.of(user));

        LoginRequest request = new LoginRequest("test_alice", TEST_CREDENTIAL);
        AuthResponse response = authService.login(request);

        assertNotNull(response);
        assertEquals("test_alice", response.getUsername());
        assertEquals(RoleType.EMPLOYEE, response.getRole());
        assertNotNull(response.getToken());
        assertTrue(tokenProvider.validateToken(response.getToken()));
    }

    @Test
    void testLogin_WrongPassword_ThrowsUnauthorized() {
        String encodedHash = passwordEncoder.encode(TEST_CREDENTIAL);
        User user = new User("test_alice", encodedHash, RoleType.EMPLOYEE, "Alice Martin");
        user.setId(1L);

        when(userRepository.findByUsername("test_alice")).thenReturn(Optional.of(user));

        LoginRequest request = new LoginRequest("test_alice", "bad_passphrase_attempt");
        assertThrows(ResponseStatusException.class, () -> authService.login(request));
    }

    @Test
    void testLogin_UserNotFound_ThrowsUnauthorized() {
        when(userRepository.findByUsername("unknown_user")).thenReturn(Optional.empty());

        LoginRequest request = new LoginRequest("unknown_user", TEST_CREDENTIAL);
        assertThrows(ResponseStatusException.class, () -> authService.login(request));
    }

    @Test
    void testRegister_Success() {
        when(userRepository.existsByUsername("test_charlie")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User u = invocation.getArgument(0);
            u.setId(5L);
            return u;
        });

        CreateUserRequest request = new CreateUserRequest("test_charlie", TEST_CREDENTIAL, RoleType.EMPLOYEE, "Charlie Dubois");
        AuthResponse response = authService.register(request);

        assertNotNull(response);
        assertEquals("test_charlie", response.getUsername());
        assertEquals(RoleType.EMPLOYEE, response.getRole());
        assertNotNull(response.getToken());
    }
}
