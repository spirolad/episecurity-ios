//
//  APIEndpoints.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

public enum APIEndpoint {
    // Auth
    case login
    case register
    case me
    case logout
    
    // Users
    case getUsers
    case getUser(id: Int64)
    case createUser
    case updateUserRole(id: Int64)
    case updateUserManager(id: Int64)
    case updateProfile
    case deleteUser(id: Int64)
    
    // Admin
    case adminGetUsers
    case adminUpdateUserRole(id: Int64)
    case adminDeleteUser(id: Int64)
    
    // Messages
    case analyzeMessage
    case sendMessage
    case getMessages
    case getMessage(id: Int64)
    
    // Signalements
    case getSignalements(status: String? = nil)
    case getSignalement(id: Int64)
    case updateSignalementStatus(id: Int64)
    
    public var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
        case .register:
            return "/api/auth/register"
        case .me:
            return "/api/auth/me"
        case .logout:
            return "/api/auth/logout"
            
        case .getUsers:
            return "/api/users"
        case .getUser(let id):
            return "/api/users/\(id)"
        case .createUser:
            return "/api/users"
        case .updateUserRole(let id):
            return "/api/users/\(id)/role"
        case .updateUserManager(let id):
            return "/api/admin/users/\(id)/manager"
        case .updateProfile:
            return "/api/users/me"
        case .deleteUser(let id):
            return "/api/users/\(id)"
            
        case .adminGetUsers:
            return "/api/admin/users"
        case .adminUpdateUserRole(let id):
            return "/api/admin/users/\(id)/role"
        case .adminDeleteUser(let id):
            return "/api/admin/users/\(id)"
            
        case .analyzeMessage:
            return "/api/messages/analyze"
        case .sendMessage:
            return "/api/messages"
        case .getMessages:
            return "/api/messages"
        case .getMessage(let id):
            return "/api/messages/\(id)"
            
        case .getSignalements:
            return "/api/signalements"
        case .getSignalement(let id):
            return "/api/signalements/\(id)"
        case .updateSignalementStatus(let id):
            return "/api/signalements/\(id)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .login, .register, .logout, .createUser, .analyzeMessage, .sendMessage:
            return .post
        case .me, .getUsers, .getUser, .adminGetUsers, .getMessages, .getMessage, .getSignalements, .getSignalement:
            return .get
        case .updateUserRole, .updateUserManager, .updateProfile, .adminUpdateUserRole, .updateSignalementStatus:
            return .patch
        case .deleteUser, .adminDeleteUser:
            return .delete
        }
    }
    
    public func url(baseURL: String = AppConfig.baseURL) -> URL? {
        var urlString = "\(baseURL)\(path)"
        if case .getSignalements(let status) = self, let status = status, !status.isEmpty {
            urlString += "?status=\(status)"
        }
        return URL(string: urlString)
    }
}
