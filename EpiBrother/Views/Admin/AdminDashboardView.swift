//
//  AdminDashboardView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct AdminDashboardView: View {
    @StateObject private var viewModel = AdminDashboardViewModel()
    @StateObject private var authService = AuthService.shared
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Statistiques globales
                    statsGrid
                    
                    // Raccourcis d'administration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gestion des équipes & Comptes")
                            .font(.headline)
                        
                        NavigationLink(destination: UserManagementView()) {
                            HStack {
                                Image(systemName: "person.3.sequence.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Annuaire et affectations")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Gérer les rôles, comptes et liaisons salariés / managers")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Journal d'audit de sécurité
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(.purple)
                            Text("Journal d'audit de conformité")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 8) {
                            if viewModel.auditLogs.isEmpty {
                                Text("Aucun événement d'audit récent.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.auditLogs) { log in
                                    auditLogRow(for: log)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Administration")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.loadData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(
                title: "Utilisateurs",
                value: "\(viewModel.totalUsersCount)",
                icon: "person.2.fill",
                color: .blue
            )
            
            statCard(
                title: "Salariés",
                value: "\(viewModel.employeeCount)",
                icon: "person.fill",
                color: .teal
            )
            
            statCard(
                title: "Managers",
                value: "\(viewModel.managerCount)",
                icon: "person.badge.shield.checkmark.fill",
                color: .orange
            )
            
            statCard(
                title: "Alertes en cours",
                value: "\(viewModel.pendingAlertsCount)",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title.bold())
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
    
    private func auditLogRow(for log: AuditLog) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.action)
                    .font(.caption.bold())
                    .foregroundColor(.purple)
                Spacer()
                Text(log.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text("\(log.targetResource) • Par: \(log.actorUsername)")
                .font(.caption)
                .foregroundColor(.primary)
            
            Text(log.details)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Divider()
        }
        .padding(.vertical, 2)
    }
}
