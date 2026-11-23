//
//  ManagerAlertService.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public protocol ManagerAlertServiceProtocol {
    func fetchAlerts(status: AlertStatus?) async throws -> [ManagerAlert]
    func fetchAlertById(id: Int64) async throws -> ManagerAlert
    func updateAlertStatus(id: Int64, status: AlertStatus) async throws -> ManagerAlert
    func takeOwnership(id: Int64) async throws -> ManagerAlert
    func closeAlert(id: Int64) async throws -> ManagerAlert
    func dismissAlert(id: Int64) async throws -> ManagerAlert
    func getAnalysisReport(for alert: ManagerAlert) -> AnalysisReport
}

public class ManagerAlertService: ManagerAlertServiceProtocol {
    public static let shared = ManagerAlertService()
    
    private let networkClient: NetworkClientProtocol
    private let secureStorage: SecureStorageService
    private let database: DatabaseManager
    
    private let cacheKey = "cached_manager_alerts"
    
    public init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        secureStorage: SecureStorageService = SecureStorageService.shared,
        database: DatabaseManager = DatabaseManager.shared
    ) {
        self.networkClient = networkClient
        self.secureStorage = secureStorage
        self.database = database
    }
    
    public func fetchAlerts(status: AlertStatus? = nil) async throws -> [ManagerAlert] {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        do {
            let alerts: [ManagerAlert] = try await networkClient.execute(
                endpoint: .getSignalements(status: status?.rawValue),
                body: nil,
                token: token
            )
            database.save(alerts, forKey: cacheKey)
            return alerts
        } catch {
            if let cached = database.load(forKey: cacheKey, as: [ManagerAlert].self) {
                if let status = status {
                    return cached.filter { $0.status == status }
                }
                return cached
            }
            throw error
        }
    }
    
    public func fetchAlertById(id: Int64) async throws -> ManagerAlert {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        return try await networkClient.execute(
            endpoint: .getSignalement(id: id),
            body: nil,
            token: token
        )
    }
    
    public func updateAlertStatus(id: Int64, status: AlertStatus) async throws -> ManagerAlert {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        let body = UpdateSignalementDTO(status: status.rawValue)
        let updated: ManagerAlert = try await networkClient.execute(
            endpoint: .updateSignalementStatus(id: id),
            body: body,
            token: token
        )
        
        // Mettre à jour le cache local
        var cached = database.load(forKey: cacheKey, as: [ManagerAlert].self) ?? []
        if let index = cached.firstIndex(where: { $0.id == id }) {
            cached[index] = updated
            database.save(cached, forKey: cacheKey)
        }
        
        return updated
    }
    
    public func takeOwnership(id: Int64) async throws -> ManagerAlert {
        return try await updateAlertStatus(id: id, status: .reviewed)
    }
    
    public func closeAlert(id: Int64) async throws -> ManagerAlert {
        return try await updateAlertStatus(id: id, status: .resolved)
    }
    
    public func dismissAlert(id: Int64) async throws -> ManagerAlert {
        return try await updateAlertStatus(id: id, status: .dismissed)
    }
    
    public func getAnalysisReport(for alert: ManagerAlert) -> AnalysisReport {
        let text = (alert.messageContent ?? "").lowercased()
        let category: AnalysisCategory
        var terms: [String] = []
        
        if text.contains("epita") || text.contains("fuite") || text.contains("confidentiel") || text.contains("secret") {
            category = .dlp
            if text.contains("epita") { terms.append("Epita") }
            if text.contains("fuite") { terms.append("fuite") }
            if text.contains("confidentiel") { terms.append("confidentiel") }
        } else if text.contains("insulte") || text.contains("harc") || text.contains("idiot") {
            category = .toxicity
            terms.append("langage inapproprié")
        } else {
            category = .policyViolation
            terms.append("règlement intérieur")
        }
        
        let explanation = "Le système d'analyse automatisée a détecté une anomalie sémantique ou une mention de données sensibles dans ce message échangé sur la plateforme interne."
        let action = alert.severity == .critical ? "Prendre contact immédiatement avec le référent conformité/DPO et planifier un entretien avec les parties prenantes." : "Vérifier le contexte de l'échange et clôturer ou avertir le collaborateur si nécessaire."
        
        return AnalysisReport(
            alertId: alert.id,
            category: category,
            confidenceScore: alert.severity == .critical ? 0.98 : 0.88,
            triggeredTerms: terms.isEmpty ? ["terme sensible"] : terms,
            explanation: explanation,
            suggestedAction: action
        )
    }
}
