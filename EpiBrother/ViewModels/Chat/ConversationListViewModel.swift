//
//  ConversationListViewModel.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

@MainActor
public class ConversationListViewModel: ObservableObject {
    @Published public var conversations: [Conversation] = []
    @Published public var colleagues: [User] = []
    @Published public var searchText = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var showError = false
    @Published public var selectedUserForNewChat: User?
    
    private let conversationService: ConversationServiceProtocol
    private let authService: AuthService
    
    public init(
        conversationService: ConversationServiceProtocol = ConversationService.shared,
        authService: AuthService = AuthService.shared
    ) {
        self.conversationService = conversationService
        self.authService = authService
    }
    
    public var filteredConversations: [Conversation] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return conversations
        }
        return conversations.filter {
            $0.contact.fullName.localizedCaseInsensitiveContains(searchText) ||
            $0.contact.username.localizedCaseInsensitiveContains(searchText) ||
            ($0.lastMessage?.decryptedContent.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public var filteredColleagues: [User] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return colleagues
        }
        return colleagues.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let fetchedColleagues = conversationService.fetchColleagues()
            async let fetchedConversations = conversationService.fetchConversations()
            
            let (colls, convs) = try await (fetchedColleagues, fetchedConversations)
            self.colleagues = colls
            self.conversations = convs
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Impossible de charger les conversations : \(error.localizedDescription)"
            self.showError = true
        }
    }
}
