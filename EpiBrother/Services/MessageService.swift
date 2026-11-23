//
//  MessageService.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

public protocol MessageServiceProtocol {
    func sendMessage(recipientId: Int64, content: String, encrypt: Bool) async throws -> Message
    func fetchMessages() async throws -> [Message]
    func fetchMessagesForConversation(contactId: Int64) async throws -> [Message]
}

public class MessageService: MessageServiceProtocol {
    public static let shared = MessageService()
    
    private let networkClient: NetworkClientProtocol
    private let cryptoManager: CryptoManager
    private let secureStorage: SecureStorageService
    private let database: DatabaseManager
    
    private let cacheKey = "cached_messages"
    
    public init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        cryptoManager: CryptoManager = CryptoManager.shared,
        secureStorage: SecureStorageService = SecureStorageService.shared,
        database: DatabaseManager = DatabaseManager.shared
    ) {
        self.networkClient = networkClient
        self.cryptoManager = cryptoManager
        self.secureStorage = secureStorage
        self.database = database
    }
    
    public func sendMessage(recipientId: Int64, content: String, encrypt: Bool = true) async throws -> Message {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        let processedContent: String
        if encrypt {
            processedContent = try cryptoManager.encrypt(plainText: content)
        } else {
            processedContent = content
        }
        
        let currentUser = secureStorage.getCurrentUser()
        let body = SendMessageDTO(
            senderId: currentUser?.id,
            recipientId: recipientId,
            content: processedContent
        )
        
        let sentMessage: Message = try await networkClient.execute(
            endpoint: .sendMessage,
            body: body,
            token: token
        )
        
        // Mise à jour du cache local
        var cached = database.load(forKey: cacheKey, as: [Message].self) ?? []
        cached.removeAll { $0.id == sentMessage.id }
        cached.append(sentMessage)
        database.save(cached, forKey: cacheKey)
        
        return sentMessage
    }
    
    public func fetchMessages() async throws -> [Message] {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        do {
            let messages: [Message] = try await networkClient.execute(
                endpoint: .getMessages,
                body: nil,
                token: token
            )
            database.save(messages, forKey: cacheKey)
            return messages
        } catch {
            if let cached = database.load(forKey: cacheKey, as: [Message].self) {
                return cached
            }
            throw error
        }
    }
    
    public func fetchMessagesForConversation(contactId: Int64) async throws -> [Message] {
        let allMessages = try await fetchMessages()
        guard let currentUserId = secureStorage.getCurrentUser()?.id else {
            return []
        }
        
        let conversationMessages = allMessages.filter { msg in
            let isIncoming = msg.sender.id == contactId && (msg.recipient == nil || msg.recipient?.id == currentUserId)
            let isOutgoing = msg.sender.id == currentUserId && msg.recipient?.id == contactId
            return isIncoming || isOutgoing
        }
        
        return conversationMessages.sorted { $0.createdAt < $1.createdAt }
    }
}
