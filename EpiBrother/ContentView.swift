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
                        showingInitialLegalNotice = true
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

                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.crop.circle")
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

                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.crop.circle")
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

                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.crop.circle")
                    }
            }
        }
    }
}

private struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @State private var username = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var isSaving = false
    @State private var statusMessage: String?
    @State private var isError = false

    var body: some View {
        NavigationView {
            Form {
                if let user = authService.currentUser {
                    Section(header: Text("Compte")) {
                        HStack {
                            Text("Rôle")
                            Spacer()
                            BadgeView(role: user.role)
                        }
                        if let managerName = user.managerName {
                            Text("Manager : \(managerName)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Informations personnelles")) {
                    TextField("Identifiant", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Nom complet", text: $fullName)
                    SecureField("Nouveau mot de passe", text: $password)
                }

                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .foregroundColor(isError ? .red : .green)
                    }
                }

                Section {
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Enregistrer")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving)
                }

                Section {
                    Button(role: .destructive, action: {
                        authService.logout()
                    }) {
                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Mon profil")
            .onAppear {
                if let user = authService.currentUser {
                    username = user.username
                    fullName = user.fullName
                }
            }
        }
    }

    private func saveProfile() {
        isSaving = true
        statusMessage = nil
        isError = false

        Task {
            do {
                _ = try await authService.updateProfile(
                    username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                    fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password.isEmpty ? nil : password
                )
                password = ""
                statusMessage = "Profil enregistré."
            } catch {
                isError = true
                statusMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
}

#Preview {
    ContentView()
}
