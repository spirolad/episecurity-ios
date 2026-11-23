//
//  EpiBrotherApp.swift
//  EpiBrother
//
//  Created by Guest User on 19/11/2026.
//

import SwiftUI

@main
struct EpiBrotherApp: App {
    init() {
        // Vérification d'intégrité de l'environnement (détection d'appareil compromis)
        if JailbreakDetector.shared.isJailbroken() {
            print("⚠️ Avertissement de sécurité : l'environnement d'exécution présente des vulnérabilités d'intégrité.")
        }
        
        // Initialisation des notifications
        NotificationService.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
