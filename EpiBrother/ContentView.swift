//
//  ContentView.swift
//  EpiBrother
//
//  Created by Guest User on 19/11/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingInitialLegalNotice = false
    
    var body: some View {
        ZStack {
            if authService.isAuthenticated, let user = authService.currentUser {
                authenticatedTabView(for: user)
                    .onAppear {
                        if !SecureStorageService.shared.hasAcceptedLegalNotice {
                            showingInitialLegalNotice = true
                        }
                    }
            } else {
                LoginView()
            }
            
            // Notification / Alerte toast en incrustation
            if let notification = notificationService.activeNotification {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: notification.isAlert ? "exclamationmark.triangle.fill" : "bell.fill")
                            .foregroundColor(notification.isAlert ? .red : .blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(notification.title)
                                .font(.subheadline.bold())
                            Text(notification.body)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .zIndex(100)
            }
        }
        .sheet(isPresented: $showingInitialLegalNotice) {
            LegalNoticeView {
                showingInitialLegalNotice = false
            }
        }
        .task {
            _ = await authService.restoreSession()
        }
    }
    
    @ViewBuilder
    private func authenticatedTabView(for user: User) -> some View {
        TabView {
            switch user.role {
            case .employee:
                // 1. Messagerie
                ConversationListView()
                    .tabItem {
                        Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                
                // 2. Information légale / Droits
                LegalNoticeView()
                    .tabItem {
                        Label("Information légale", systemImage: "hand.raised.square.fill")
                    }
                
            case .manager:
                // 1. Signalements d'équipe reçus de l'IA
                ManagerDashboardView()
                    .tabItem {
                        Label("Signalements", systemImage: "exclamationmark.shield.fill")
                    }
                
                // 2. Messagerie
                ConversationListView()
                    .tabItem {
                        Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                
                // 3. Information légale
                LegalNoticeView()
                    .tabItem {
                        Label("Information légale", systemImage: "hand.raised.square.fill")
                    }
                
            case .admin:
                // 1. Tableau de bord Administrateur
                AdminDashboardView()
                    .tabItem {
                        Label("Tableau de bord", systemImage: "chart.bar.xaxis")
                    }
                
                // 2. Gestion des comptes et affectations
                UserManagementView()
                    .tabItem {
                        Label("Comptes & Équipes", systemImage: "person.3.sequence.fill")
                    }
                
                // 3. Signalements
                ManagerDashboardView()
                    .tabItem {
                        Label("Signalements", systemImage: "exclamationmark.shield.fill")
                    }
                
                // 4. Messagerie
                ConversationListView()
                    .tabItem {
                        Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                
                // 5. Notice de conformité CNIL
                LegalNoticeView()
                    .tabItem {
                        Label("Conformité CNIL", systemImage: "hand.raised.square.fill")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
