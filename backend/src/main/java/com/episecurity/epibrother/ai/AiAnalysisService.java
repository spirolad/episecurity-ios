package com.episecurity.epibrother.ai;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.regex.Pattern;

/**
 * Service d'analyse IA des messages.
 * Actuellement configuré avec une règle heuristique vérifiant la présence du terme "Epita"
 * (remplaçable ultérieurement par un appel à un modèle d'IA / LLM).
 */
@Service
public class AiAnalysisService {

    private static final Logger log = LoggerFactory.getLogger(AiAnalysisService.class);
    private static final Pattern EPITA_PATTERN = Pattern.compile("\\bepita\\b", Pattern.CASE_INSENSITIVE);
    private static final Pattern DLP_PATTERN = Pattern.compile(
            "(mot de passe|password|clé secrète|secret key|api[_ -]?key|token|fuite|confidentiel)",
            Pattern.CASE_INSENSITIVE);
    private static final Pattern TOXIC_PATTERN = Pattern.compile(
            "(menace|harcèlement|harcelement|insulte|raciste|sexiste|humiliation)",
            Pattern.CASE_INSENSITIVE);

    /**
     * Analyse le contenu d'un message pour détecter d'éventuelles infractions ou termes sensibles.
     *
     * @param content Le texte du message envoyé depuis l'application iOS / Swift
     * @return AiAnalysisResult contenant le statut de signalement, le motif et la sévérité
     */
    public AiAnalysisResult analyze(String content) {
        if (content == null || content.isBlank()) {
            return AiAnalysisResult.clean();
        }
        if (content.startsWith("ENC:")) {
            return AiAnalysisResult.clean();
        }

        log.info("Lancement de l'analyse IA sur le message (taille: {} caractères)...", content.length());

        // Règle temporaire : détection de la mention 'Epita' (insensible à la casse)
        boolean containsEpita = EPITA_PATTERN.matcher(content).find() || content.toLowerCase().contains("epita");

        if (containsEpita) {
            String reason = "Analyse IA (filtre de conformité) : Détection du mot-clé sensible 'Epita' dans le message";
            String severity = "HIGH";
            double confidenceScore = 0.95;

            log.warn("⚠️ ALERTE IA DÉCLENCHÉE : Le message contient le terme 'Epita' ! Sévérité: {}", severity);
            return AiAnalysisResult.flagged(reason, severity, confidenceScore);
        }

        java.util.regex.Matcher dlpMatcher = DLP_PATTERN.matcher(content);
        if (dlpMatcher.find()) {
            return AiAnalysisResult.flagged(
                    "Analyse IA (DLP) : mot sensible détecté",
                    "HIGH",
                    0.88);
        }

        java.util.regex.Matcher toxicMatcher = TOXIC_PATTERN.matcher(content);
        if (toxicMatcher.find()) {
            return AiAnalysisResult.flagged(
                    "Analyse IA (conformité) : comportement potentiellement toxique détecté",
                    "MEDIUM",
                    0.82);
        }

        // Si aucune anomalie détectée
        log.info("Message analysé par l'IA : Aucun comportement suspect détecté.");
        return AiAnalysisResult.clean();
    }
}
