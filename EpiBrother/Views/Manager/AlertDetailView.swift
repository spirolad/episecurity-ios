//
//  AlertDetailView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct AlertDetailView: View {
    @StateObject private var viewModel: AlertDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(alert: ManagerAlert) {
        _viewModel = StateObject(wrappedValue: AlertDetailViewModel(alert: alert))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Bannière de statut & sévérité
                HStack {
                    BadgeView(severity: viewModel.alert.severity)
                    BadgeView(status: viewModel.alert.status)
                    Spacer()
                    Text(viewModel.alert.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
                
                // Message de confirmation d'action
                if let msg = viewModel.actionSuccessMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(msg)
                            .font(.footnote.bold())
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(10)
                }
                
                // Message d'erreur s'il y a lieu
                if let error = viewModel.errorMessage, viewModel.showError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Carte du message suspect intercepté
                VStack(alignment: .leading, spacing: 12) {
                    Text("Contenu du message signalé")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.alert.decryptedMessageContent)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                            )
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Expéditeur :")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.alert.sender?.fullName ?? "Inconnu")
                                    .font(.subheadline.bold())
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Destinataire :")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.alert.recipient?.fullName ?? "Tous")
                                    .font(.subheadline.bold())
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                // Rapport d'analyse par l'IA
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "cpu")
                            .foregroundColor(.purple)
                        Text("Analyse automatisée de conformité")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Motif de détection :")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.alert.reason)
                                .font(.subheadline.bold())
                                .foregroundColor(.red)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Catégorie :")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.analysisReport.category.label)
                                .font(.subheadline.bold())
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Score de confiance de l'IA :")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(viewModel.analysisReport.confidenceScore * 100))%")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Mots ou patterns sensibles détectés :")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                ForEach(viewModel.analysisReport.triggeredTerms, id: \.self) { term in
                                    Text(term)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.12))
                                        .foregroundColor(.red)
                                        .cornerRadius(6)
                                }
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recommandation d'action :")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text(viewModel.analysisReport.suggestedAction)
                                .font(.footnote)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                // Actions de gestion du manager
                VStack(spacing: 12) {
                    Text("Actions Managériales")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if viewModel.alert.status == .pending {
                        Button(action: {
                            Task {
                                await viewModel.takeOwnership()
                            }
                        }) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                Text("Prendre en charge le signalement")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    if viewModel.alert.status != .resolved {
                        Button(action: {
                            Task {
                                await viewModel.closeAlert()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Clôturer / Résoudre l'incident")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    if viewModel.alert.status != .dismissed {
                        Button(action: {
                            Task {
                                await viewModel.dismissAlert()
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.bin.fill")
                                Text("Classer sans suite (Faux positif)")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(.secondary)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Détail du signalement #\(viewModel.alert.id)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
