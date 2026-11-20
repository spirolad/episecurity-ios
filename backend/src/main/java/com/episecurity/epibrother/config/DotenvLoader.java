package com.episecurity.epibrother.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.*;

/**
 * Charge les variables d'environnement depuis le fichier .env (en priorité)
 * ou .env.example (en fallback) afin qu'aucun secret ne soit écrit en dur dans le code.
 */
public class DotenvLoader {

    private static final Logger log = LoggerFactory.getLogger(DotenvLoader.class);

    public static Map<String, Object> load() {
        Map<String, Object> props = new LinkedHashMap<>();

        File envFile = findFile(".env");
        File exampleFile = findFile(".env.example");

        // 1. Charger .env.example en base (valeurs par défaut/templates)
        if (exampleFile != null && exampleFile.exists()) {
            Map<String, String> exampleValues = parseFile(exampleFile);
            props.putAll(exampleValues);
            log.info("Fichier .env.example chargé depuis: {}", exampleFile.getAbsolutePath());
        }

        // 2. Charger .env EN PRIORITÉ (écrase .env.example et fournit les vrais secrets)
        if (envFile != null && envFile.exists()) {
            Map<String, String> envValues = parseFile(envFile);
            props.putAll(envValues);
            log.info("Fichier .env chargé EN PRIORITÉ depuis: {}", envFile.getAbsolutePath());
        } else {
            log.warn("Fichier .env non trouvé, utilisation des variables d'environnement système ou .env.example.");
        }

        // Appliquer aux propriétés système de la JVM pour que Spring ${VAR} les résolve partout
        props.forEach((k, v) -> {
            if (System.getProperty(k) == null && v != null) {
                System.setProperty(k, v.toString());
            }
        });

        return props;
    }

    private static File findFile(String filename) {
        List<Path> candidatePaths = List.of(
                Path.of(filename),
                Path.of("..", filename),
                Path.of("../..", filename),
                Path.of("backend", filename)
        );

        for (Path p : candidatePaths) {
            File file = p.toFile();
            if (file.exists() && file.isFile()) {
                return file;
            }
        }
        return null;
    }

    private static Map<String, String> parseFile(File file) {
        Map<String, String> result = new LinkedHashMap<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(file, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                // Ignorer les commentaires et lignes vides
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                int eqIndex = line.indexOf('=');
                if (eqIndex > 0) {
                    String key = line.substring(0, eqIndex).trim();
                    String value = line.substring(eqIndex + 1).trim();

                    // Nettoyer les quotes d'encadrement si présentes
                    if ((value.startsWith("\"") && value.endsWith("\"")) ||
                        (value.startsWith("'") && value.endsWith("'"))) {
                        if (value.length() >= 2) {
                            value = value.substring(1, value.length() - 1);
                        }
                    }
                    result.put(key, value);
                }
            }
        } catch (IOException e) {
            log.error("Erreur lors de la lecture de {}", file.getAbsolutePath(), e);
        }
        return result;
    }
}
