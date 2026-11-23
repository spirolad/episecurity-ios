//
//  AppConfig.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public struct AppConfig {
    public static let appName = "EpiBrother"
    public static let appVersion = "1.0.0"
    
    #if DEBUG
    public static let defaultBaseURL = "http://localhost:8080"
    #else
    public static let defaultBaseURL = "https://epibrother.internal.epita.fr"
    #endif
    
    public static var baseURL: String {
        get {
            UserDefaults.standard.string(forKey: "custom_api_base_url") ?? defaultBaseURL
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "custom_api_base_url")
        }
    }
    
    public static var webSocketURL: String {
        let base = baseURL
            .replacingOccurrences(of: "http://", with: "ws://")
            .replacingOccurrences(of: "https://", with: "wss://")
        return "\(base)/ws"
    }
    
    // Configuration de sécurité
    public static let tokenKeychainKey = "com.episecurity.epibrother.jwtToken"
    public static let userKeychainKey = "com.episecurity.epibrother.currentUser"
    public static let encryptionKeyKeychainKey = "com.episecurity.epibrother.cryptoKey"
    public static let legalConsentKey = "com.episecurity.epibrother.legalConsentAccepted"
}
