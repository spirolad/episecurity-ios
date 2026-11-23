//
//  AdminService.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public protocol AdminServiceProtocol {
    func fetchUsers() async throws -> [User]
    func createUser(username: String, password: String, role: Role, fullName: String) async throws -> User
    func updateUserRole(userId: Int64, newRole: Role) async throws -> User
    func deleteUser(userId: Int64) async throws
    func assignEmployeeToManager(employeeId: Int64, managerId: Int64?) async throws -> User
    func getAuditLogs() -> [AuditLog]
}

public class AdminService: AdminServiceProtocol {
    public static let shared = AdminService()
    
    private let networkClient: NetworkClientProtocol
    private let secureStorage: SecureStorageService
    private let database: DatabaseManager
    
    private let usersCacheKey = "cached_admin_users"
    private let teamAssignmentsKey = "team_manager_assignments"
    private let auditLogsKey = "system_audit_logs"
    
    public init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        secureStorage: SecureStorageService = SecureStorageService.shared,
        database: DatabaseManager = DatabaseManager.shared
    ) {
        self.networkClient = networkClient
        self.secureStorage = secureStorage
        self.database = database
    }
    
    public func fetchUsers() async throws -> [User] {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        do {
            var users: [User] = try await networkClient.execute(
                endpoint: .adminGetUsers,
                body: nil,
                token: token
            )
            
            // Enrichir avec les affectations manager sauvegardées
            let assignments = getStoredAssignments()
            for i in 0..<users.count {
                if let mgrId = assignments[users[i].id] {
                    users[i].managerId = mgrId
                    if let mgr = users.first(where: { $0.id == mgrId }) {
                        users[i].managerName = mgr.fullName
                    }
                }
            }
            
            database.save(users, forKey: usersCacheKey)
            return users
        } catch {
            if let cached = database.load(forKey: usersCacheKey, as: [User].self) {
                return cached
            }
            throw error
        }
    }
    
    public func createUser(username: String, password: String, role: Role, fullName: String) async throws -> User {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        struct CreateUserDTO: Codable {
            let username: String
            let password: String
            let role: String
            let fullName: String
        }
        
        let body = CreateUserDTO(
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            role: role.rawValue,
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        let createdUser: User = try await networkClient.execute(
            endpoint: .createUser,
            body: body,
            token: token
        )
        
        logAction(
            action: "CREATION_UTILISATEUR",
            target: "\(createdUser.username) (id: \(createdUser.id))",
            details: "Rôle attribué: \(role.displayName)"
        )
        
        return createdUser
    }
    
    public func updateUserRole(userId: Int64, newRole: Role) async throws -> User {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        struct UpdateRoleDTO: Codable {
            let role: String
        }
        
        let body = UpdateRoleDTO(role: newRole.rawValue)
        let updatedUser: User = try await networkClient.execute(
            endpoint: .adminUpdateUserRole(id: userId),
            body: body,
            token: token
        )
        
        logAction(
            action: "MODIFICATION_ROLE",
            target: "Utilisateur id: \(userId)",
            details: "Nouveau rôle: \(newRole.displayName)"
        )
        
        return updatedUser
    }
    
    public func deleteUser(userId: Int64) async throws {
        guard let token = secureStorage.getToken() else {
            throw APIError.unauthorized
        }
        
        try await networkClient.executeWithoutResponse(
            endpoint: .adminDeleteUser(id: userId),
            body: nil,
            token: token
        )
        
        logAction(
            action: "SUPPRESSION_UTILISATEUR",
            target: "Utilisateur id: \(userId)",
            details: "Suppression définitive du compte"
        )
    }
    
    public func assignEmployeeToManager(employeeId: Int64, managerId: Int64?) async throws -> User {
        var assignments = getStoredAssignments()
        if let managerId = managerId {
            assignments[employeeId] = managerId
        } else {
            assignments.removeValue(forKey: employeeId)
        }
        database.save(assignments, forKey: teamAssignmentsKey)
        
        // Recharger l'utilisateur
        var users = try await fetchUsers()
        guard let index = users.firstIndex(where: { $0.id == employeeId }) else {
            throw APIError.notFound("Salarié introuvable")
        }
        
        users[index].managerId = managerId
        if let managerId = managerId, let manager = users.first(where: { $0.id == managerId }) {
            users[index].managerName = manager.fullName
        } else {
            users[index].managerName = nil
        }
        
        logAction(
            action: "AFFECTATION_EQUIPE",
            target: "Salarié id: \(employeeId)",
            details: managerId != nil ? "Affecté au Manager id: \(managerId!)" : "Désassigné de son manager"
        )
        
        return users[index]
    }
    
    public func getAuditLogs() -> [AuditLog] {
        return database.load(forKey: auditLogsKey, as: [AuditLog].self) ?? [
            AuditLog(
                action: "SYSTEM_START",
                actorUsername: "system",
                targetResource: "EpiBrother Engine",
                details: "Démarrage des contrôles de sécurité et de conformité"
            )
        ]
    }
    
    private func getStoredAssignments() -> [Int64: Int64] {
        return database.load(forKey: teamAssignmentsKey, as: [Int64: Int64].self) ?? [
            3: 2, // Alice -> Manager Dupont par défaut
            4: 2  // Bob -> Manager Dupont par défaut
        ]
    }
    
    private func logAction(action: String, target: String, details: String) {
        var logs = getAuditLogs()
        let currentUsername = secureStorage.getCurrentUser()?.username ?? "admin"
        let newLog = AuditLog(
            action: action,
            actorUsername: currentUsername,
            targetResource: target,
            details: details
        )
        logs.insert(newLog, at: 0)
        database.save(logs, forKey: auditLogsKey)
    }
}
