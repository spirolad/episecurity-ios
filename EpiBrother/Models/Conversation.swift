//
//  Conversation.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public struct Conversation: Identifiable, Codable, Hashable {
    public let id: String
    public let contact: User
    public var lastMessage: Message?
    public var unreadCount: Int
    public var updatedAt: Date
    
    public init(
        contact: User,
        lastMessage: Message? = nil,
        unreadCount: Int = 0,
        updatedAt: Date = Date()
    ) {
        self.id = "conv_\(contact.id)"
        self.contact = contact
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.updatedAt = updatedAt
    }
}
