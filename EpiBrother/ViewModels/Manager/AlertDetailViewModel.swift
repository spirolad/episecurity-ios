//
//  AlertDetailViewModel.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

@MainActor
public class AlertDetailViewModel: ObservableObject {
    @Published public var alert: ManagerAlert
    @Published public var analysisReport: AnalysisReport
    @Published public var isProcessing: Bool = false
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false
    @Published public var actionSuccessMessage: String?
    
    private let alertService: ManagerAlertServiceProtocol
    
    public init(
        alert: ManagerAlert,
        alertService: ManagerAlertServiceProtocol = ManagerAlertService.shared
    ) {
        self.alert = alert
        self.alertService = alertService
        self.analysisReport = alertService.getAnalysisReport(for: alert)
    }
    
    public func takeOwnership() async {
        isProcessing = true
        errorMessage = nil
        do {
            let updated = try await alertService.takeOwnership(id: alert.id)
            self.alert = updated
            self.actionSuccessMessage = "Signalement pris en charge avec succès."
            self.isProcessing = false
        } catch {
            self.isProcessing = false
            self.errorMessage = "Impossible de prendre en charge : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func closeAlert() async {
        isProcessing = true
        errorMessage = nil
        do {
            let updated = try await alertService.closeAlert(id: alert.id)
            self.alert = updated
            self.actionSuccessMessage = "Signalement clôturé et résolu avec succès."
            self.isProcessing = false
        } catch {
            self.isProcessing = false
            self.errorMessage = "Impossible de clôturer : \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    public func dismissAlert() async {
        isProcessing = true
        errorMessage = nil
        do {
            let updated = try await alertService.dismissAlert(id: alert.id)
            self.alert = updated
            self.actionSuccessMessage = "Signalement classé sans suite."
            self.isProcessing = false
        } catch {
            self.isProcessing = false
            self.errorMessage = "Impossible de classer le signalement : \(error.localizedDescription)"
            self.showError = true
        }
    }
}
