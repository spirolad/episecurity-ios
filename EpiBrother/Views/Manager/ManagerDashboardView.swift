//
//  ManagerDashboardView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct ManagerDashboardView: View {
    @StateObject private var viewModel = ManagerDashboardViewModel()
    @StateObject private var authService = AuthService.shared
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cartes d'indicateurs KPI en tête de tableau
                    kpiHeaderView
                    
                    // Sélecteur de filtre de statut
                    Picker("Statut", selection: $viewModel.selectedStatus) {
                        Text("Tous").tag(AlertStatus?.none)
                        Text("En attente").tag(AlertStatus?.some(.pending))
                        Text("Pris en charge").tag(AlertStatus?.some(.reviewed))
                        Text("Clôturés").tag(AlertStatus?.some(.resolved))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Liste des signalements
                    if viewModel.isLoading && viewModel.alerts.isEmpty {
                        LoadingView(message: "Analyse des remontées...")
                    } else if viewModel.filteredAlerts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.green)
                            Text("Aucun signalement trouvé")
                                .font(.headline)
                            Text("Aucune infraction aux règles internes n'a été détectée dans les critères sélectionnés.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.filteredAlerts) { alert in
                                NavigationLink(destination: AlertDetailView(alert: alert)) {
                                    alertRow(for: alert)
                                }
                                .swipeActions(edge: .leading) {
                                    if alert.status == .pending {
                                        Button {
                                            Task {
                                                await viewModel.quickTakeOwnership(alert: alert)
                                            }
                                        } label: {
                                            Label("Prendre en charge", systemImage: "hand.raised.fill")
                                        }
                                        .tint(.blue)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    if alert.status != .resolved {
                                        Button {
                                            Task {
                                                await viewModel.quickClose(alert: alert)
                                            }
                                        } label: {
                                            Label("Clôturer", systemImage: "checkmark.circle.fill")
                                        }
                                        .tint(.green)
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            await viewModel.loadAlerts()
                        }
                    }
                }
            }
            .navigationTitle("Signalements d'équipe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.loadAlerts()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.loadAlerts()
            }
        }
    }
    
    private var kpiHeaderView: some View {
        HStack(spacing: 12) {
            kpiCard(
                title: "En attente",
                count: viewModel.pendingCount,
                color: .red,
                icon: "exclamationmark.triangle.fill"
            )
            
            kpiCard(
                title: "Critiques",
                count: viewModel.criticalCount,
                color: .purple,
                icon: "flame.fill"
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func kpiCard(title: String, count: Int, color: Color, icon: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Text("\(count)")
                    .font(.title2.bold())
                    .foregroundColor(color)
            }
            Spacer()
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color.opacity(0.8))
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    private func alertRow(for alert: ManagerAlert) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                BadgeView(severity: alert.severity)
                BadgeView(status: alert.status)
                Spacer()
                Text(alert.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(alert.reason)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Text(alert.decryptedMessageContent)
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "person.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("De : \(alert.sender?.fullName ?? "Inconnu")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                if let recipient = alert.recipient {
                    Text("À : \(recipient.fullName)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
