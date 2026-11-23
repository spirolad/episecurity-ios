//
//  AdminDashboardViewModel.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

@MainActor
public class AdminDashboardViewModel: ObservableObject {
    @Published public var totalUsersCount: Int = 0
    @Published public var employeeCount: Int = 0
    @Published public var managerCount: Int = 0
    @Published public var pendingAlertsCount: Int = 0
    @Published public var auditLogs: [AuditLog] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false
    
    private let adminService: AdminServiceProtocol
    private let alertService: ManagerAlertServiceProtocol
    
    public init(
        adminService: AdminServiceProtocol = AdminService.shared,
        alertService: ManagerAlertServiceProtocol = ManagerAlertService.shared
    ) {
        self.adminService = adminService
        self.alertService = alertService
    }
    
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let usersTask = adminService.fetchUsers()
            async let alertsTask = alertService.fetchAlerts(status: nil)
            
            let (users, alerts) = try await (usersTask, alertsTask)
            self.totalUsersCount = users.count
            self.employeeCount = users.filter { $0.role == .employee }.count
            self.managerCount = users.filter { $0.role == .manager }.count
            self.pendingAlertsCount = alerts.filter { $0.status == .pending }.count
            self.auditLogs = adminService.getAuditLogs()
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Erreur de chargement du tableau de bord : \(error.localizedDescription)"
            self.showError = true
        }
    }
}
