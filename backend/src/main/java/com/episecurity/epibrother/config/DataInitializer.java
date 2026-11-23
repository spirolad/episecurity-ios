package com.episecurity.epibrother.config;

import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import com.episecurity.epibrother.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;

@Configuration
public class DataInitializer {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    @Value("${app.seed.admin-password:${DEFAULT_ADMIN_PASSWORD:}}")
    private String adminPassword;

    @Value("${app.seed.manager-password:${DEFAULT_MANAGER_PASSWORD:}}")
    private String managerPassword;

    @Value("${app.seed.alice-password:${DEFAULT_ALICE_PASSWORD:}}")
    private String alicePassword;

    @Value("${app.seed.bob-password:${DEFAULT_BOB_PASSWORD:}}")
    private String bobPassword;

    @Bean
    public CommandLineRunner initUsers(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (StringUtils.hasText(adminPassword)) {
                initUserIfNotExists(userRepository, passwordEncoder, "admin", adminPassword, RoleType.ADMIN, "Administrateur Sécurité");
            }
            if (StringUtils.hasText(managerPassword)) {
                initUserIfNotExists(userRepository, passwordEncoder, "manager_dupont", managerPassword, RoleType.MANAGER, "Jean Dupont (Manager)");
            }
            if (StringUtils.hasText(alicePassword)) {
                initUserIfNotExists(userRepository, passwordEncoder, "alice", alicePassword, RoleType.EMPLOYEE, "Alice Martin");
            }
            if (StringUtils.hasText(bobPassword)) {
                initUserIfNotExists(userRepository, passwordEncoder, "bob", bobPassword, RoleType.EMPLOYEE, "Bob Durand");
            }

            userRepository.findByUsername("manager_dupont").ifPresent(manager ->
                    userRepository.findByUsername("alice").ifPresent(alice -> {
                        alice.setManager(manager);
                        userRepository.save(alice);
                    })
            );
            userRepository.findByUsername("manager_dupont").ifPresent(manager ->
                    userRepository.findByUsername("bob").ifPresent(bob -> {
                        bob.setManager(manager);
                        userRepository.save(bob);
                    })
            );
        };
    }

    private void initUserIfNotExists(UserRepository userRepository,
                                     PasswordEncoder passwordEncoder,
                                     String username,
                                     String rawPassword,
                                     RoleType role,
                                     String fullName) {
        userRepository.findByUsername(username).ifPresentOrElse(
                user -> {
                    if (!StringUtils.hasText(user.getPassword()) || "defaultPassword".equals(user.getPassword())) {
                        user.setPassword(passwordEncoder.encode(rawPassword));
                        userRepository.save(user);
                        log.info("Mot de passe initialisé pour l'utilisateur: {}", username);
                    }
                },
                () -> {
                    User newUser = new User(username, passwordEncoder.encode(rawPassword), role, fullName);
                    userRepository.save(newUser);
                    log.info("Utilisateur initialisé: {} avec le rôle {}", username, role);
                }
        );
    }
}
