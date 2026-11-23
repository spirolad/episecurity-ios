//
//  ManagerDashboardViewModel.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

@MainActor
public class ManagerDashboardViewModel: ObservableObject {
    @Published public var alerts: [ManagerAlert] = []
    @Published public var selectedStatus: AlertStatus? = nil
    @Published public var selectedSeverity: AlertSeverity? = nil
    @Published public var searchText: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false
    
    private let alertService: ManagerAlertServiceProtocol
    
    public init(alertService: ManagerAlertServiceProtocol = ManagerAlertService.shared) {
        self.alertService = alertService
    }
    
    public var filteredAlerts: [ManagerAlert] {
        return alerts.filter { alert in
            let matchesStatus = (selectedStatus == nil) || (alert.status == selectedStatus)
            let matchesSeverity = (selectedSeverity == nil) || (alert.severity == selectedSeverity)
            let matchesSearch = searchText.isEmpty ||
                (alert.messageContent?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (alert.sender?.fullName.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (alert.reason.localizedCaseInsensitiveContains(searchText))
            
            return matchesStatus && matchesSeverity && matchesSearch
        }
    }
    
    public var pendingCount: Int {
        return alerts.filter { $0.status == .pending }.count
    }
    
    public var criticalCount: Int {
        return alerts.filter { $0.severity == .critical && $0.status == .pending }.count
    }
    
    public func loadAlerts() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await alertService.fetchAlerts(status: selectedStatus)
            self.alerts = fetched
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Impossible de récupérer les signalements : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func quickTakeOwnership(alert: ManagerAlert) async {
        do {
            let updated = try await alertService.takeOwnership(id: alert.id)
            if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
                alerts[index] = updated
            }
        } catch {
            self.errorMessage = "Échec de prise en charge : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func quickClose(alert: ManagerAlert) async {
        do {
            let updated = try await alertService.closeAlert(id: alert.id)
            if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
                alerts[index] = updated
            }
        } catch {
            self.errorMessage = "Échec de clôture : \(error.localizedDescription)"
            self.showError = true
        }
    }
}
