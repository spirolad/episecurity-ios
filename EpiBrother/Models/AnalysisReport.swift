//
//  AnalysisReport.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public enum AnalysisCategory: String, Codable, CaseIterable {
    case dlp = "FUITE_DE_DONNEES"
    case toxicity = "PROPOS_INAPPROPRIES"
    case policyViolation = "VIOLATION_REGLEMENT"
    case complianceRisk = "RISQUE_CONFORMITE"
    
    public var label: String {
        switch self {
        case .dlp: return "Fuite de données (DLP)"
        case .toxicity: return "Propos inappropriés / Harcèlement"
        case .policyViolation: return "Violation du règlement intérieur"
        case .complianceRisk: return "Risque de conformité"
        }
    }
}

public struct AnalysisReport: Identifiable, Codable, Hashable {
    public let id: UUID
    public let alertId: Int64
    public let category: AnalysisCategory
    public let confidenceScore: Double
    public let triggeredTerms: [String]
    public let explanation: String
    public let suggestedAction: String
    
    public init(
        id: UUID = UUID(),
        alertId: Int64,
        category: AnalysisCategory,
        confidenceScore: Double,
        triggeredTerms: [String],
        explanation: String,
        suggestedAction: String
    ) {
        self.id = id
        self.alertId = alertId
        self.category = category
        self.confidenceScore = confidenceScore
        self.triggeredTerms = triggeredTerms
        self.explanation = explanation
        self.suggestedAction = suggestedAction
    }
}
