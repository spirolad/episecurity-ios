//
//  MessageBubbleView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct MessageBubbleView: View {
    let message: Message
    let isCurrentUser: Bool
    
    public init(message: Message, isCurrentUser: Bool) {
        self.message = message
        self.isCurrentUser = isCurrentUser
    }
    
    public var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Alerte si le message a été signalé par l'IA
                if message.flaggedByAi {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(.orange)
                        Text("Signalé par le filtre de conformité IA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(6)
                }
                
                // Bulle de message
                VStack(alignment: .trailing, spacing: 6) {
                    Text(message.decryptedContent)
                        .font(.body)
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4) {
                        if message.isEncrypted {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9))
                                .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .secondary)
                        }
                        
                        Text(message.formattedTime)
                            .font(.system(size: 10))
                            .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleBackground)
                .cornerRadius(16)
            }
            
            if !isCurrentUser {
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
    
    private var bubbleBackground: Color {
        if isCurrentUser {
            return message.flaggedByAi ? Color.orange : Color.blue
        } else {
            return Color(.secondarySystemBackground)
        }
    }
}
