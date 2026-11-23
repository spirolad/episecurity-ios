//
//  AuditLog.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public struct AuditLog: Identifiable, Codable, Hashable {
    public let id: UUID
    public let timestamp: Date
    public let action: String
    public let actorUsername: String
    public let targetResource: String
    public let details: String
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        action: String,
        actorUsername: String,
        targetResource: String,
        details: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.actorUsername = actorUsername
        self.targetResource = targetResource
        self.details = details
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}
