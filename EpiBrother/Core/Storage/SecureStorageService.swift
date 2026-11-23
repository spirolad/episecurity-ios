//
//  SecureStorageService.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public class SecureStorageService {
    public static let shared = SecureStorageService()
    
    private let keychain = KeychainManager.shared
    private let database = DatabaseManager.shared
    
    private init() {}
    
    // MARK: - Token Management
    public func saveToken(_ token: String) {
        keychain.save(key: AppConfig.tokenKeychainKey, string: token)
    }
    
    public func getToken() -> String? {
        return keychain.getString(key: AppConfig.tokenKeychainKey)
    }
    
    public func clearToken() {
        keychain.delete(key: AppConfig.tokenKeychainKey)
    }
    
    // MARK: - Current User
    public func saveCurrentUser(_ user: User) {
        if let data = try? NetworkClient.jsonEncoder.encode(user) {
            keychain.save(key: AppConfig.userKeychainKey, data: data)
        }
    }
    
    public func getCurrentUser() -> User? {
        guard let data = keychain.get(key: AppConfig.userKeychainKey) else { return nil }
        return try? NetworkClient.jsonDecoder.decode(User.self, from: data)
    }
    
    public func clearCurrentUser() {
        keychain.delete(key: AppConfig.userKeychainKey)
    }
    
    // MARK: - Legal Consent (CNIL / RGPD)
    public var hasAcceptedLegalNotice: Bool {
        get {
            UserDefaults.standard.bool(forKey: AppConfig.legalConsentKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConfig.legalConsentKey)
        }
    }
    
    // MARK: - Clear All
    public func clearSession() {
        clearToken()
        clearCurrentUser()
        // Conserver le consentement légal ou le réinitialiser si souhaité
    }
}
