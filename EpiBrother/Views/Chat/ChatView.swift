//
//  ChatView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @StateObject private var authService = AuthService.shared
    
    public init(contact: User) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(contact: contact))
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Bandeau d'information Sécurité & Modération
            securityBanner
            
            // Bannière d'alerte immédiate si le dernier message a été intercepté par l'IA
            if viewModel.lastSentWasFlagged {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundColor(.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Avertissement de conformité")
                            .font(.caption.bold())
                            .foregroundColor(.red)
                        Text("Votre message enfreint les règles internes et a été automatiquement transmis à votre manager.")
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Button(action: {
                        viewModel.lastSentWasFlagged = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(Color.red.opacity(0.12))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 4)
            }
            
            // Liste des messages de la conversation
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 6) {
                        if viewModel.messages.isEmpty && !viewModel.isLoading {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("Aucun message pour le moment")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Démarrez la conversation avec \(viewModel.contact.fullName)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(viewModel.messages) { message in
                                let isMe = message.sender.id == authService.currentUser?.id
                                MessageBubbleView(message: message, isCurrentUser: isMe)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Barre de saisie et d'envoi
            messageInputBar
        }
        .navigationTitle(viewModel.contact.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(viewModel.contact.fullName)
                        .font(.headline)
                    HStack(spacing: 4) {
                        BadgeView(role: viewModel.contact.role)
                            .scaleEffect(0.85)
                    }
                }
            }
        }
        .task {
            await viewModel.loadMessages()
        }
    }
    
    private var securityBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.isEncryptionEnabled ? "lock.shield.fill" : "lock.open.fill")
                .foregroundColor(viewModel.isEncryptionEnabled ? .green : .orange)
            
            Text(viewModel.isEncryptionEnabled ? "Chiffrement AES-256 activé" : "Chiffrement désactivé")
                .font(.caption2.bold())
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                viewModel.isEncryptionEnabled.toggle()
            }) {
                Text(viewModel.isEncryptionEnabled ? "Désactiver" : "Activer")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.tertiarySystemBackground))
    }
    
    private var messageInputBar: some View {
        HStack(spacing: 10) {
            TextField("Rédiger un message...", text: $viewModel.messageInput)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
            
            Button(action: {
                Task {
                    await viewModel.sendMessage()
                }
            }) {
                if viewModel.isSending {
                    ProgressView()
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
            }
            .disabled(viewModel.messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}
