package com.episecurity.epibrother.config;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class DotenvLoaderTest {

    @Test
    void testLoad_ShouldLoadPropertiesFromEnvFileInPriority() {
        Map<String, Object> props = DotenvLoader.load();

        assertNotNull(props);
        assertFalse(props.isEmpty(), "Les propriétés depuis .env ou .env.example doivent être chargées");
        assertTrue(props.containsKey("JWT_SECRET"), "JWT_SECRET doit être présent dans les propriétés chargées");
        assertTrue(props.containsKey("POSTGRES_DB"), "POSTGRES_DB doit être présent dans les propriétés chargées");

        // Vérifier que la valeur a bien été injectée dans System.getProperty
        assertNotNull(System.getProperty("JWT_SECRET"), "System property JWT_SECRET doit être définie");
    }
}
