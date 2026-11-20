package com.episecurity.epibrother;

import com.episecurity.epibrother.config.DotenvLoader;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class EpiBrotherApplication {

    public static void main(String[] args) {
        // Chargement du fichier .env en priorité avant l'initialisation de Spring Boot
        DotenvLoader.load();
        SpringApplication.run(EpiBrotherApplication.class, args);
    }
}
