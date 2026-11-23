//
//  ChatViewModel.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

@MainActor
public class ChatViewModel: ObservableObject {
    public let contact: User
    
    @Published public var messages: [Message] = []
    @Published public var messageInput: String = ""
    @Published public var isEncryptionEnabled: Bool = true
    @Published public var isSending: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false
    @Published public var lastSentWasFlagged: Bool = false
    
    private let messageService: MessageServiceProtocol
    private let authService: AuthService
    
    public init(
        contact: User,
        messageService: MessageServiceProtocol = MessageService.shared,
        authService: AuthService = AuthService.shared
    ) {
        self.contact = contact
        self.messageService = messageService
        self.authService = authService
    }
    
    public func loadMessages() async {
        isLoading = true
        do {
            let fetched = try await messageService.fetchMessagesForConversation(contactId: contact.id)
            self.messages = fetched
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Erreur de chargement des messages : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func sendMessage() async {
        let textToSend = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }
        
        isSending = true
        errorMessage = nil
        lastSentWasFlagged = false
        
        do {
            let sentMessage = try await messageService.sendMessage(
                recipientId: contact.id,
                content: textToSend,
                encrypt: isEncryptionEnabled
            )
            
            self.messages.append(sentMessage)
            self.messageInput = ""
            self.isSending = false
            
            if sentMessage.flaggedByAi {
                self.lastSentWasFlagged = true
            }
        } catch {
            self.isSending = false
            self.errorMessage = "Échec de l'envoi du message : \(error.localizedDescription)"
            self.showError = true
        }
    }
}
