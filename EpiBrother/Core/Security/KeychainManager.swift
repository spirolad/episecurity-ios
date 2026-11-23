//
//  KeychainManager.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Security

public class KeychainManager {
    public static let shared = KeychainManager()
    
    private let service = "com.episecurity.epibrother"
    private var inMemoryFallback: [String: Data] = [:]
    
    private init() {}
    
    @discardableResult
    public func save(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else {
            // Sauvegarde de secours en mémoire si environnement restreint (simulateur/preview)
            inMemoryFallback[key] = data
            return true
        }
    }
    
    @discardableResult
    public func save(key: String, string: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(key: key, data: data)
    }
    
    public func get(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return data
        }
        
        return inMemoryFallback[key]
    }
    
    public func getString(key: String) -> String? {
        guard let data = get(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    @discardableResult
    public func delete(key: String) -> Bool {
        inMemoryFallback.removeValue(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    @discardableResult
    public func clearAll() -> Bool {
        inMemoryFallback.removeAll()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
