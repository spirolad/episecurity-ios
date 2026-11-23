//
//  AuthService.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

public protocol AuthServiceProtocol: ObservableObject {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    var token: String? { get }
    func login(username: String, password: String) async throws -> User
    func register(username: String, password: String, role: Role, fullName: String) async throws -> User
    func updateProfile(username: String?, fullName: String?, password: String?) async throws -> User
    func logout()
    func restoreSession() async -> Bool
}

@MainActor
public class AuthService: ObservableObject, AuthServiceProtocol {
    public static let shared = AuthService()
    
    @Published public var currentUser: User?
    @Published public var isAuthenticated: Bool = false
    @Published public var token: String?
    
    private let networkClient: NetworkClientProtocol
    private let secureStorage: SecureStorageService
    
    public init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        secureStorage: SecureStorageService = SecureStorageService.shared
    ) {
        self.networkClient = networkClient
        self.secureStorage = secureStorage
        
        // Tentative de restauration de session synchrone préliminaire
        if let savedToken = secureStorage.getToken(), let savedUser = secureStorage.getCurrentUser() {
            self.token = savedToken
            self.currentUser = savedUser
            self.isAuthenticated = true
        }
    }
    
    public func login(username: String, password: String) async throws -> User {
        struct LoginDTO: Codable {
            let username: String
            let password: String
        }
        
        let body = LoginDTO(username: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
        let authResponse: AuthResponseDTO = try await networkClient.execute(
            endpoint: .login,
            body: body,
            token: nil
        )
        
        let user = authResponse.toUser
        self.token = authResponse.token
        self.currentUser = user
        self.isAuthenticated = true
        
        // Sauvegarde sécurisée de la session
        secureStorage.saveToken(authResponse.token)
        secureStorage.saveCurrentUser(user)
        
        // Connexion au WebSocket
        WebSocketClient.shared.connect(token: authResponse.token)
        
        return user
    }
    
    public func register(username: String, password: String, role: Role, fullName: String) async throws -> User {
        struct RegisterDTO: Codable {
            let username: String
            let password: String
            let role: String
            let fullName: String
        }
        
        let body = RegisterDTO(
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            role: role.rawValue,
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        let authResponse: AuthResponseDTO = try await networkClient.execute(
            endpoint: .register,
            body: body,
            token: nil
        )
        
        let user = authResponse.toUser
        self.token = authResponse.token
        self.currentUser = user
        self.isAuthenticated = true
        
        secureStorage.saveToken(authResponse.token)
        secureStorage.saveCurrentUser(user)
        
        WebSocketClient.shared.connect(token: authResponse.token)
        return user
    }

    public func updateProfile(username: String? = nil, fullName: String? = nil, password: String? = nil) async throws -> User {
        guard let savedToken = secureStorage.getToken() else {
            throw APIError.unauthorized
        }

        struct UpdateProfileDTO: Codable {
            let username: String?
            let fullName: String?
            let password: String?
        }

        let body = UpdateProfileDTO(username: username, fullName: fullName, password: password)
        let updatedUser: User = try await networkClient.execute(
            endpoint: .updateProfile,
            body: body,
            token: savedToken
        )

        self.currentUser = updatedUser
        secureStorage.saveCurrentUser(updatedUser)
        return updatedUser
    }
    
    public func logout() {
        if let savedToken = secureStorage.getToken() {
            Task {
                try? await networkClient.executeWithoutResponse(
                    endpoint: .logout,
                    body: nil,
                    token: savedToken
                )
            }
        }

        self.token = nil
        self.currentUser = nil
        self.isAuthenticated = false
        
        secureStorage.clearSession()
        WebSocketClient.shared.disconnect()
    }
    
    public func restoreSession() async -> Bool {
        guard let savedToken = secureStorage.getToken() else {
            logout()
            return false
        }
        
        do {
            let freshUser: User = try await networkClient.execute(
                endpoint: .me,
                body: nil,
                token: savedToken
            )
            self.token = savedToken
            self.currentUser = freshUser
            self.isAuthenticated = true
            secureStorage.saveCurrentUser(freshUser)
            WebSocketClient.shared.connect(token: savedToken)
            return true
        } catch {
            print("Session expirée ou invalide: \(error)")
            logout()
            return false
        }
    }
}
