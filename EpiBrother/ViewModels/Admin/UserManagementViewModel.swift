//
//  UserManagementViewModel.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

@MainActor
public class UserManagementViewModel: ObservableObject {
    @Published public var users: [User] = []
    @Published public var selectedRoleFilter: Role? = nil
    @Published public var searchText: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false
    
    // Formulaire de création de compte
    @Published public var showCreateUserSheet: Bool = false
    @Published public var newUsername: String = ""
    @Published public var newPassword: String = ""
    @Published public var newFullName: String = ""
    @Published public var newRole: Role = .employee
    
    // Affectation Salarié -> Manager
    @Published public var showAssignManagerSheet: Bool = false
    @Published public var selectedUserForAssignment: User?
    @Published public var selectedManagerId: Int64?
    
    private let adminService: AdminServiceProtocol
    
    public init(adminService: AdminServiceProtocol = AdminService.shared) {
        self.adminService = adminService
    }
    
    public var managers: [User] {
        return users.filter { $0.role == .manager }
    }
    
    public var filteredUsers: [User] {
        return users.filter { user in
            let matchesRole = (selectedRoleFilter == nil) || (user.role == selectedRoleFilter)
            let matchesSearch = searchText.isEmpty ||
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.username.localizedCaseInsensitiveContains(searchText)
            return matchesRole && matchesSearch
        }
    }
    
    public func loadUsers() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await adminService.fetchUsers()
            self.users = fetched
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Impossible de récupérer les utilisateurs : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func createUser() async {
        guard !newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Veuillez spécifier un nom d'utilisateur."
            showError = true
            return
        }
        guard !newFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Veuillez spécifier le nom complet."
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            let created = try await adminService.createUser(
                username: newUsername,
                password: newPassword.isEmpty ? "password123" : newPassword,
                role: newRole,
                fullName: newFullName
            )
            self.users.append(created)
            self.newUsername = ""
            self.newPassword = ""
            self.newFullName = ""
            self.newRole = .employee
            self.showCreateUserSheet = false
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Erreur lors de la création de l'utilisateur : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func updateUserRole(user: User, newRole: Role) async {
        do {
            let updated = try await adminService.updateUserRole(userId: user.id, newRole: newRole)
            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index].role = updated.role
            }
        } catch {
            self.errorMessage = "Échec de la modification du rôle : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func assignManager(employee: User, managerId: Int64?) async {
        do {
            let updated = try await adminService.assignEmployeeToManager(employeeId: employee.id, managerId: managerId)
            if let index = users.firstIndex(where: { $0.id == employee.id }) {
                users[index] = updated
            }
            self.showAssignManagerSheet = false
        } catch {
            self.errorMessage = "Échec de l'affectation du manager : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func deleteUser(user: User) async {
        do {
            try await adminService.deleteUser(userId: user.id)
            users.removeAll { $0.id == user.id }
        } catch {
            self.errorMessage = "Échec de la suppression de l'utilisateur : \(error.localizedDescription)"
            self.showError = true
        }
    }
}
