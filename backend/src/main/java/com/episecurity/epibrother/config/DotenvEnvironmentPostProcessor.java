package com.episecurity.epibrother.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.util.Map;

/**
 * Injecte le contenu du .env avec la plus haute priorité dans l'environnement Spring Boot.
 */
@Order(Ordered.HIGHEST_PRECEDENCE)
public class DotenvEnvironmentPostProcessor implements EnvironmentPostProcessor {

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        Map<String, Object> props = DotenvLoader.load();
        if (!props.isEmpty()) {
            environment.getPropertySources().addFirst(new MapPropertySource("dotenvProperties", props));
        }
    }
}
