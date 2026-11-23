//
//  NotificationService.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine
#if canImport(UserNotifications)
import UserNotifications
#endif

public struct InAppNotification: Identifiable {
    public let id = UUID()
    public let title: String
    public let body: String
    public let isAlert: Bool
}

@MainActor
public class NotificationService: ObservableObject {
    public static let shared = NotificationService()
    
    @Published public var activeNotification: InAppNotification?
    
    private init() {}
    
    public func requestPermission() {
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permissions de notification accordées.")
            }
        }
        #endif
    }
    
    public func showNotification(title: String, message: String, isAlert: Bool = false) {
        let notification = InAppNotification(title: title, body: message, isAlert: isAlert)
        self.activeNotification = notification
        
        #if canImport(UserNotifications)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = isAlert ? .defaultCritical : .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        #endif
        
        // Auto-dismiss in-app notification after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            if self?.activeNotification?.id == notification.id {
                self?.activeNotification = nil
            }
        }
    }
}
