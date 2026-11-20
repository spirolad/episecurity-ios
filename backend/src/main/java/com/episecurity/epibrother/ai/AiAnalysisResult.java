package com.episecurity.epibrother.ai;

public class AiAnalysisResult {

    private final boolean flagged;
    private final String reason;
    private final String severity;
    private final double confidenceScore;

    public AiAnalysisResult(boolean flagged, String reason, String severity, double confidenceScore) {
        this.flagged = flagged;
        this.reason = reason;
        this.severity = severity;
        this.confidenceScore = confidenceScore;
    }

    public static AiAnalysisResult clean() {
        return new AiAnalysisResult(false, null, "LOW", 0.0);
    }

    public static AiAnalysisResult flagged(String reason, String severity, double confidenceScore) {
        return new AiAnalysisResult(true, reason, severity, confidenceScore);
    }

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
