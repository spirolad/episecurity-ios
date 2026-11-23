//
//  ConversationService.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public protocol ConversationServiceProtocol {
    func fetchConversations() async throws -> [Conversation]
    func fetchColleagues() async throws -> [User]
}

public class ConversationService: ConversationServiceProtocol {
    public static let shared = ConversationService()
    
    private let networkClient: NetworkClientProtocol
    private let messageService: MessageServiceProtocol
    private let secureStorage: SecureStorageService
    private let database: DatabaseManager
    
    private let colleaguesCacheKey = "cached_colleagues"
    
    public init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        messageService: MessageServiceProtocol = MessageService.shared,
        secureStorage: SecureStorageService = SecureStorageService.shared,
        database: DatabaseManager = DatabaseManager.shared
    ) {
        self.networkClient = networkClient
        self.messageService = messageService
        self.secureStorage = secureStorage
        self.database = database
    }
    
    public func fetchColleagues() async throws -> [User] {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        let currentUserId = secureStorage.getCurrentUser()?.id
        
        do {
            let allUsers: [User] = try await networkClient.execute(
                endpoint: .getUsers,
                body: nil,
                token: token
            )
            
            // Exclure l'utilisateur connecté de la liste des collègues
            let colleagues = allUsers.filter { $0.id != currentUserId }
            database.save(colleagues, forKey: colleaguesCacheKey)
            return colleagues
        } catch {
            if let cached = database.load(forKey: colleaguesCacheKey, as: [User].self) {
                return cached
            }
            throw error
        }
    }
    
    public func fetchConversations() async throws -> [Conversation] {
        let colleagues = try await fetchColleagues()
        let messages = try await messageService.fetchMessages()
        guard let currentUserId = secureStorage.getCurrentUser()?.id else {
            return []
        }
        
        var conversations: [Conversation] = []
        
        for contact in colleagues {
            // Rechercher les messages échangés avec ce contact
            let contactMessages = messages.filter { msg in
                (msg.sender.id == contact.id && (msg.recipient == nil || msg.recipient?.id == currentUserId)) ||
                (msg.sender.id == currentUserId && msg.recipient?.id == contact.id)
            }.sorted { $0.createdAt > $1.createdAt }
            
            let lastMessage = contactMessages.first
            let unreadCount = contactMessages.filter { $0.sender.id == contact.id && !$0.flaggedByAi }.count
            let updatedAt = lastMessage?.createdAt ?? contact.createdAt ?? Date.distantPast
            
            conversations.append(Conversation(
                contact: contact,
                lastMessage: lastMessage,
                unreadCount: unreadCount > 0 ? 1 : 0,
                updatedAt: updatedAt
            ))
        }
        
        // Trier par date du dernier message décroissante
        return conversations.sorted { $0.updatedAt > $1.updatedAt }
    }
}
