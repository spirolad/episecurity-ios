import Foundation

public struct MessageAnalysisResult: Equatable {
    public let isFlagged: Bool
    public let reason: String?
    public let severity: String?
}

public enum MessageAnalysisDetector {
    public static func analyze(_ content: String) -> MessageAnalysisResult {
        let normalized = content.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: Locale(identifier: "fr_FR")
        ).lowercased()

        guard !normalized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return clean
        }

        if containsWholeWord("epita", in: normalized) {
            return MessageAnalysisResult(
                isFlagged: true,
                reason: "Analyse IA (filtre de conformité) : Détection du mot-clé sensible 'Epita' dans le message",
                severity: "HIGH"
            )
        }

        let dlpTerms = [
            "mot de passe", "password", "clé secrète", "secret key",
            "api key", "apikey", "api-key", "token", "fuite", "confidentiel"
        ]
        if dlpTerms.contains(where: normalized.contains) {
            return MessageAnalysisResult(
                isFlagged: true,
                reason: "Analyse IA (DLP) : mot sensible détecté",
                severity: "HIGH"
            )
        }

        let toxicTerms = [
            "menace", "harcèlement", "harcelement", "insulte", "raciste",
            "sexiste", "humiliation"
        ]
        if toxicTerms.contains(where: normalized.contains) {
            return MessageAnalysisResult(
                isFlagged: true,
                reason: "Analyse IA (conformité) : comportement potentiellement toxique détecté",
                severity: "MEDIUM"
            )
        }

        return clean
    }

    private static var clean: MessageAnalysisResult {
        MessageAnalysisResult(isFlagged: false, reason: nil, severity: nil)
    }

    private static func containsWholeWord(_ word: String, in text: String) -> Bool {
        let pattern = "(^|[^a-z0-9])\(NSRegularExpression.escapedPattern(for: word))([^a-z0-9]|$)"
        return text.range(of: pattern, options: .regularExpression) != nil
    }
}
