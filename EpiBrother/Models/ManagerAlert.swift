//
//  ManagerAlert.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import SwiftUI

public enum AlertSeverity: String, Codable, CaseIterable, Identifiable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .low: return "Faible"
        case .medium: return "Moyenne"
        case .high: return "Élevée"
        case .critical: return "Critique"
        }
    }
    
    public var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    public var iconName: String {
        switch self {
        case .low: return "info.circle"
        case .medium: return "exclamationmark.triangle"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "flame.fill"
        }
    }
}

public enum AlertStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "PENDING"
    case reviewed = "REVIEWED"
    case dismissed = "DISMISSED"
    case resolved = "RESOLVED"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .pending: return "En attente"
        case .reviewed: return "Pris en charge"
        case .dismissed: return "Classé sans suite"
        case .resolved: return "Clôturé / Résolu"
        }
    }
    
    public var color: Color {
        switch self {
        case .pending: return .red
        case .reviewed: return .blue
        case .dismissed: return .gray
        case .resolved: return .green
        }
    }
}

public struct ManagerAlert: Identifiable, Codable, Hashable {
    public let id: Int64
    public let messageId: Int64?
    public let messageContent: String?
    public let sender: User?
    public let recipient: User?
    public var reason: String
    public var severity: AlertSeverity
    public var status: AlertStatus
    public let createdAt: Date
    
    public init(
        id: Int64,
        messageId: Int64?,
        messageContent: String?,
        sender: User?,
        recipient: User?,
        reason: String,
        severity: AlertSeverity,
        status: AlertStatus,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.messageId = messageId
        self.messageContent = messageContent
        self.sender = sender
        self.recipient = recipient
        self.reason = reason
        self.severity = severity
        self.status = status
        self.createdAt = createdAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        messageId = try container.decodeIfPresent(Int64.self, forKey: .messageId)
        messageContent = try container.decodeIfPresent(String.self, forKey: .messageContent)
        sender = try container.decodeIfPresent(User.self, forKey: .sender)
        recipient = try container.decodeIfPresent(User.self, forKey: .recipient)
        reason = try container.decode(String.self, forKey: .reason)
        
        let severityString = try container.decode(String.self, forKey: .severity)
        severity = AlertSeverity(rawValue: severityString.uppercased()) ?? .high
        
        let statusString = try container.decode(String.self, forKey: .status)
        status = AlertStatus(rawValue: statusString.uppercased()) ?? .pending
        
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
    
    public var decryptedMessageContent: String {
        guard let content = messageContent else { return "Contenu non disponible" }
        return CryptoManager.shared.decrypt(cipherText: content)
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

public struct UpdateSignalementDTO: Codable {
    public let status: String
    
    public init(status: String) {
        self.status = status
    }
}
