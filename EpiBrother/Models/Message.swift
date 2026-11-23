//
//  Message.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public struct Message: Identifiable, Codable, Hashable {
    public let id: Int64
    public let sender: User
    public let recipient: User?
    public let content: String
    public let flaggedByAi: Bool
    public let createdAt: Date
    
    public init(
        id: Int64,
        sender: User,
        recipient: User?,
        content: String,
        flaggedByAi: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.content = content
        self.flaggedByAi = flaggedByAi
        self.createdAt = createdAt
    }
    
    public var decryptedContent: String {
        return CryptoManager.shared.decrypt(cipherText: content)
    }
    
    public var isEncrypted: Bool {
        return CryptoManager.shared.isEncrypted(content: content)
    }
    
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAt)
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

public struct SendMessageDTO: Codable {
    public let senderId: Int64?
    public let recipientId: Int64
    public let content: String
    public let flaggedByAi: Bool
    public let analysisReason: String?
    public let analysisSeverity: String?
    
    public init(
        senderId: Int64? = nil,
        recipientId: Int64,
        content: String,
        flaggedByAi: Bool = false,
        analysisReason: String? = nil,
        analysisSeverity: String? = nil
    ) {
        self.senderId = senderId
        self.recipientId = recipientId
        self.content = content
        self.flaggedByAi = flaggedByAi
        self.analysisReason = analysisReason
        self.analysisSeverity = analysisSeverity
    }
}
