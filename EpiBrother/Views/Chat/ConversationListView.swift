//
//  ConversationListView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct ConversationListView: View {
    @StateObject private var viewModel = ConversationListViewModel()
    @StateObject private var authService = AuthService.shared
    @State private var showLogoutConfirmation = false
    @State private var showColleaguesSheet = false
    @State private var selectedContact: User?
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Barre de recherche
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Rechercher un collègue ou un message...", text: $viewModel.searchText)
                    }
                    .padding(10)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    if viewModel.isLoading && viewModel.conversations.isEmpty {
                        LoadingView(message: "Chargement des conversations...")
                    } else {
                        List {
                            // Section Collègues de l'équipe
                            if !viewModel.filteredColleagues.isEmpty {
                                Section(header: Text("Collègues de travail")) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(viewModel.filteredColleagues) { colleague in
                                                NavigationLink(destination: ChatView(contact: colleague)) {
                                                    VStack(spacing: 6) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(colleague.role.badgeColor.opacity(0.15))
                                                                .frame(width: 52, height: 52)
                                                            Text(colleague.initials)
                                                                .font(.headline)
                                                                .foregroundColor(colleague.role.badgeColor)
                                                        }
                                                        Text(colleague.fullName.split(separator: " ").first ?? "")
                                                            .font(.caption)
                                                            .foregroundColor(.primary)
                                                            .lineLimit(1)
                                                    }
                                                    .frame(width: 64)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                            
                            // Section Conversations
                            Section(header: Text("Messages récents")) {
                                if viewModel.filteredConversations.isEmpty {
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("Aucun historique de message.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Sélectionnez un collègue ci-dessus pour lancer un échange.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                } else {
                                    ForEach(viewModel.filteredConversations) { conv in
                                        NavigationLink(destination: ChatView(contact: conv.contact)) {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle()
                                                        .fill(conv.contact.role.badgeColor.opacity(0.15))
                                                        .frame(width: 44, height: 44)
                                                    Text(conv.contact.initials)
                                                        .font(.subheadline.bold())
                                                        .foregroundColor(conv.contact.role.badgeColor)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack {
                                                        Text(conv.contact.fullName)
                                                            .font(.headline)
                                                        Spacer()
                                                        if let msg = conv.lastMessage {
                                                            Text(msg.formattedTime)
                                                                .font(.caption2)
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                    
                                                    HStack {
                                                        if let msg = conv.lastMessage {
                                                            if msg.isEncrypted {
                                                                Image(systemName: "lock.fill")
                                                                    .font(.caption2)
                                                                    .foregroundColor(.secondary)
                                                            }
                                                            Text(msg.decryptedContent)
                                                                .font(.subheadline)
                                                                .foregroundColor(.secondary)
                                                                .lineLimit(1)
                                                        } else {
                                                            Text("Démarrer la discussion")
                                                                .font(.subheadline)
                                                                .foregroundColor(.secondary)
                                                                .italic()
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        if conv.unreadCount > 0 {
                                                            Circle()
                                                                .fill(Color.blue)
                                                                .frame(width: 8, height: 8)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            await viewModel.loadData()
                        }
                    }
                }
            }
            .navigationTitle("Messagerie")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = authService.currentUser {
                        HStack(spacing: 6) {
                            BadgeView(role: user.role)
                            Text(user.username)
                                .font(.footnote.bold())
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            showLogoutConfirmation = true
                        }) {
                            Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .confirmationDialog("Déconnexion", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Déconnexion", role: .destructive) {
                    authService.logout()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Voulez-vous vraiment vous déconnecter d'EpiBrother ?")
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}
