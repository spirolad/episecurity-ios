package com.episecurity.epibrother.ai;

/**
 * Résultat immuable de l'analyse IA d'un message.
 */
public record AiAnalysisResult(
        boolean flagged,
        String reason,
        String severity,
        double confidenceScore
) {

    public static AiAnalysisResult clean() {
        return new AiAnalysisResult(false, null, "LOW", 0.0);
    }

    public static AiAnalysisResult flagged(String reason, String severity, double confidenceScore) {
        return new AiAnalysisResult(true, reason, severity, confidenceScore);
    }

    // Méthodes de compatibilité JavaBean
    public boolean isFlagged() {
        return flagged;
    }

    public String getReason() {
        return reason;
    }

    public String getSeverity() {
        return severity;
    }

    public double getConfidenceScore() {
        return confidenceScore;
    }
}
