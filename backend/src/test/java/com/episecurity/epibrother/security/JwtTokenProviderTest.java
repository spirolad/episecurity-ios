package com.episecurity.epibrother.security;

import com.episecurity.epibrother.model.enums.RoleType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class JwtTokenProviderTest {

    private JwtTokenProvider jwtTokenProvider;
    private final String testSigningKey = "dummy_mock_jwt_signing_key_for_unit_tests_only_do_not_use_in_prod!";
    private final long expirationMs = 3600000; // 1 heure

    @BeforeEach
    void setUp() {
        jwtTokenProvider = new JwtTokenProvider(testSigningKey, expirationMs);
    }

    @Test
    void testGenerateAndValidateToken_Success() {
        String token = jwtTokenProvider.generateToken("alice", 1L, RoleType.EMPLOYEE);

        assertNotNull(token);
        assertTrue(jwtTokenProvider.validateToken(token));
        assertEquals("alice", jwtTokenProvider.getUsernameFromToken(token));
        assertEquals(1L, jwtTokenProvider.getUserIdFromToken(token));
        assertEquals("EMPLOYEE", jwtTokenProvider.getRoleFromToken(token));
    }

    @Test
    void testGenerateTokenForAdmin_ShouldContainAdminRole() {
        String token = jwtTokenProvider.generateToken("admin", 99L, RoleType.ADMIN);

        assertNotNull(token);
        assertTrue(jwtTokenProvider.validateToken(token));
        assertEquals("admin", jwtTokenProvider.getUsernameFromToken(token));
        assertEquals(99L, jwtTokenProvider.getUserIdFromToken(token));
        assertEquals("ADMIN", jwtTokenProvider.getRoleFromToken(token));
    }

    @Test
    void testGenerateTokenForManager_ShouldContainManagerRole() {
        String token = jwtTokenProvider.generateToken("manager_dupont", 42L, RoleType.MANAGER);

        assertNotNull(token);
        assertTrue(jwtTokenProvider.validateToken(token));
        assertEquals("manager_dupont", jwtTokenProvider.getUsernameFromToken(token));
        assertEquals(42L, jwtTokenProvider.getUserIdFromToken(token));
        assertEquals("MANAGER", jwtTokenProvider.getRoleFromToken(token));
    }

    @Test
    void testValidateToken_InvalidToken_ShouldReturnFalse() {
        assertFalse(jwtTokenProvider.validateToken("invalid.token.signature"));
        assertFalse(jwtTokenProvider.validateToken(""));
        assertFalse(jwtTokenProvider.validateToken(null));
    }
}
