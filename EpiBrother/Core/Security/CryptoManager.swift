//
//  CryptoManager.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import CryptoKit

public class CryptoManager {
    public static let shared = CryptoManager()
    
    private let prefix = "ENC:"
    private var symmetricKey: SymmetricKey
    
    private init() {
        if let storedKeyData = KeychainManager.shared.get(key: AppConfig.encryptionKeyKeychainKey) {
            self.symmetricKey = SymmetricKey(data: storedKeyData)
        } else {
            // Création d'une clé AES 256 bits par défaut
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            KeychainManager.shared.save(key: AppConfig.encryptionKeyKeychainKey, data: keyData)
            self.symmetricKey = newKey
        }
    }
    
    /// Chiffre le message à l'aide d'AES-GCM (Frontend)
    public func encrypt(plainText: String) throws -> String {
        guard let data = plainText.data(using: .utf8) else {
            return plainText
        }
        
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
        guard let combinedData = sealedBox.combined else {
            return plainText
        }
        
        return prefix + combinedData.base64EncodedString()
    }
    
    /// Déchiffre le message chiffré à l'aide d'AES-GCM (Frontend)
    public func decrypt(cipherText: String) -> String {
        guard isEncrypted(content: cipherText) else {
            // Message non chiffré (ou en clair)
            return cipherText
        }
        
        let base64String = String(cipherText.dropFirst(prefix.count))
        guard let data = Data(base64Encoded: base64String) else {
            return cipherText
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8) ?? cipherText
        } catch {
            print("Erreur de déchiffrement: \(error.localizedDescription)")
            return cipherText
        }
    }
    
    /// Indique si un message est chiffré
    public func isEncrypted(content: String) -> Bool {
        return content.hasPrefix(prefix)
    }
    
    /// Permet de définir une clé partagée spécifique (ex: négociée par échange de clés)
    public func setCustomSharedKey(_ keyData: Data) {
        self.symmetricKey = SymmetricKey(data: keyData)
        KeychainManager.shared.save(key: AppConfig.encryptionKeyKeychainKey, data: keyData)
    }
}
