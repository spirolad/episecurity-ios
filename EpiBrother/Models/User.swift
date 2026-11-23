//
//  User.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public struct User: Identifiable, Codable, Hashable {
    public let id: Int64
    public var username: String
    public var role: Role
    public var fullName: String
    public var createdAt: Date?
    public var managerId: Int64?
    public var managerName: String?
    
    public init(
        id: Int64,
        username: String,
        role: Role,
        fullName: String,
        createdAt: Date? = nil,
        managerId: Int64? = nil,
        managerName: String? = nil
    ) {
        self.id = id
        self.username = username
        self.role = role
        self.fullName = fullName
        self.createdAt = createdAt
        self.managerId = managerId
        self.managerName = managerName
    }
    
    public var initials: String {
        let parts = fullName.split(separator: " ")
        if parts.count >= 2, let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(username.prefix(2)).uppercased()
    }
}

public struct AuthResponseDTO: Codable {
    public let token: String
    public let type: String
    public let id: Int64
    public let username: String
    public let fullName: String
    public let role: Role
    
    public var toUser: User {
        return User(id: id, username: username, role: role, fullName: fullName)
    }
}
