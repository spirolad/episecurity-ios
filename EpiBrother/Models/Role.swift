//
//  Role.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import SwiftUI

public enum Role: String, Codable, CaseIterable, Identifiable, Comparable {
    case employee = "EMPLOYEE"
    case manager = "MANAGER"
    case admin = "ADMIN"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .employee:
            return "Salarié"
        case .manager:
            return "Manager"
        case .admin:
            return "Administrateur"
        }
    }
    
    public var iconName: String {
        switch self {
        case .employee:
            return "person.fill"
        case .manager:
            return "person.badge.shield.checkmark.fill"
        case .admin:
            return "shield.fill"
        }
    }
    
    public var badgeColor: Color {
        switch self {
        case .employee:
            return .blue
        case .manager:
            return .orange
        case .admin:
            return .purple
        }
    }
    
    public var hierarchyLevel: Int {
        switch self {
        case .employee:
            return 1
        case .manager:
            return 2
        case .admin:
            return 3
        }
    }
    
    public static func < (lhs: Role, rhs: Role) -> Bool {
        return lhs.hierarchyLevel < rhs.hierarchyLevel
    }
}
