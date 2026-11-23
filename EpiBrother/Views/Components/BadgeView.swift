//
//  BadgeView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct BadgeView: View {
    let title: String
    let color: Color
    var icon: String? = nil
    
    public init(title: String, color: Color, icon: String? = nil) {
        self.title = title
        self.color = color
        self.icon = icon
    }
    
    public init(role: Role) {
        self.title = role.displayName
        self.color = role.badgeColor
        self.icon = role.iconName
    }
    
    public init(severity: AlertSeverity) {
        self.title = severity.displayName
        self.color = severity.color
        self.icon = severity.iconName
    }
    
    public init(status: AlertStatus) {
        self.title = status.displayName
        self.color = status.color
        self.icon = nil
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2.bold())
            }
            Text(title)
                .font(.caption.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundColor(color)
        .background(color.opacity(0.15))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
