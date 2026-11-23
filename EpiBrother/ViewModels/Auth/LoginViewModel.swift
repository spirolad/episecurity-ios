//
//  LoginViewModel.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

@MainActor
public class LoginViewModel: ObservableObject {
    @Published public var username = ""
    @Published public var password = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var showError = false
    
    // Inscription
    @Published public var showRegisterSheet = false
    @Published public var regUsername = ""
    @Published public var regPassword = ""
    @Published public var regFullName = ""
    @Published public var regRole: Role = .employee
    
    // Information légale (RGPD / CNIL)
    @Published public var showLegalNotice = false
    
    private let authService: AuthService
    private let secureStorage: SecureStorageService
    
    public init(
        authService: AuthService = AuthService.shared,
        secureStorage: SecureStorageService = SecureStorageService.shared
    ) {
        self.authService = authService
        self.secureStorage = secureStorage
    }
    
    public func login() async {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Veuillez saisir votre nom d'utilisateur."
            showError = true
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Veuillez saisir votre mot de passe."
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            _ = try await authService.login(username: username, password: password)
            isLoading = false
            
            // Si l'utilisateur se connecte pour la première fois et n'a pas validé l'information légale
            if !secureStorage.hasAcceptedLegalNotice {
                showLegalNotice = true
            }
        } catch let apiError as APIError {
            isLoading = false
            errorMessage = apiError.localizedDescription
            showError = true
        } catch {
            isLoading = false
            errorMessage = "Identifiants invalides ou service indisponible."
            showError = true
        }
    }
    
    public func register() async {
        guard !regUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Veuillez renseigner un identifiant."
            showError = true
            return
        }
        guard !regPassword.isEmpty else {
            errorMessage = "Veuillez renseigner un mot de passe."
            showError = true
            return
        }
        guard !regFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Veuillez renseigner le nom complet."
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            _ = try await authService.register(
                username: regUsername,
                password: regPassword,
                role: .employee,
                fullName: regFullName
            )
            isLoading = false
            showRegisterSheet = false
            
            if !secureStorage.hasAcceptedLegalNotice {
                showLegalNotice = true
            }
        } catch let apiError as APIError {
            isLoading = false
            errorMessage = apiError.localizedDescription
            showError = true
        } catch {
            isLoading = false
            errorMessage = "Impossible de créer le compte : \(error.localizedDescription)"
            showError = true
        }
    }
    
    // Remplissage rapide pour les tests ou la démonstration
    public func fillTestAccount(username: String, pass: String = "password123") {
        self.username = username
        self.password = pass
    }
}
