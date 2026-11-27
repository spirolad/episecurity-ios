//
//  LoginView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header avec Logo et Présentation
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                            
                            Text("EpiBrother")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Messagerie interne d'entreprise sécurisée avec analyse de conformité")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 30)
                        
                        // Message d'erreur s'il existe
                        if let error = viewModel.errorMessage, viewModel.showError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Formulaire de connexion
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                TextField("Nom d'utilisateur", text: $viewModel.username)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            
                            SecureFieldView("Mot de passe", text: $viewModel.password)
                            
                            Button(action: {
                                Task {
                                    await viewModel.login()
                                }
                            }) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 8)
                                    }
                                    Text("Se connecter")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showRegisterSheet) {
                registerSheetView
            }
        }
    }
    
    private var registerSheetView: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations du compte")) {
                    TextField("Identifiant (username)", text: $viewModel.regUsername)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Nom complet (ex: Jean Martin)", text: $viewModel.regFullName)
                    SecureField("Mot de passe", text: $viewModel.regPassword)
                }
                
                Section(header: Text("Rôle du compte")) {
                    Text("Salarié")
                        .foregroundColor(.secondary)
                }
                
                Section(footer: Text("En créant un compte, vous acceptez les modalités de modération et d'analyse IA des messages conformément au règlement intérieur.")) {
                    Button(action: {
                        Task {
                            await viewModel.register()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Créer mon compte")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Nouveau compte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.showRegisterSheet = false
                    }
                }
            }
        }
    }
}
