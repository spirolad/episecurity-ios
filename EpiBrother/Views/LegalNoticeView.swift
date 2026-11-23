//
//  LegalNoticeView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct LegalNoticeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasScrolledToBottom = false
    var onAccept: (() -> Void)? = nil
    
    public init(onAccept: (() -> Void)? = nil) {
        self.onAccept = onAccept
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // En-tête
                    HStack(spacing: 14) {
                        Image(systemName: "hand.raised.square.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notice d'information légale")
                                .font(.title2.bold())
                            Text("Conformité RGPD & Règlement Intérieur")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Section 1: Finalité et cadre légal
                    Group {
                        Text("1. Cadre du dispositif et finalité")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("L’application EpiBrother est un outil de messagerie professionnelle interne. Conformément aux recommandations de la CNIL et au droit du travail, un dispositif d'analyse automatisée par intelligence artificielle est mis en place sur les flux de communication internes. Ce traitement a pour unique finalité la prévention des fuites d'informations confidentielles (DLP), la détection de propos contraires aux règlements intérieurs (harcèlement, menaces) et la sécurité des données de l'entreprise.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Section 2: Données collectées et analysées
                    Group {
                        Text("2. Données collectées et analysées")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            bulletPoint(title: "Contenu textuel des messages", desc: "Seuls les messages envoyés sur les canaux professionnels font l'objet d'une analyse automatisée.")
                            bulletPoint(title: "Métadonnées techniques", desc: "Identifiants de l'expéditeur et du destinataire, horodatage, statut du message.")
                            bulletPoint(title: "Chiffrement", desc: "Les messages sont chiffrés de bout en bout pour garantir la confidentialité vis-à-vis des tiers.")
                        }
                    }
                    
                    // Section 3: Modalités de signalement des messages
                    Group {
                        Text("3. Modalités de signalement automatique")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Lorsqu’un message est identifié par le modèle d'IA comme potentiellement contraire aux règles de l'entreprise (fuite de secrets d'affaires, termes offensants), une alerte est transmise au manager concerné.\n\nLe manager reçoit le motif de la détection et le niveau de sévérité associé afin d'instruire la situation en toute impartialité et d'adopter les mesures appropriées.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Section 4: Droits des salariés (CNIL & RGPD)
                    Group {
                        Text("4. Vos droits (Accès, Rectification, Réclamation)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez d'un droit d'accès, de rectification et d'opposition pour motifs légitimes aux données vous concernant, en vous adressant au Délégué à la Protection des Données (DPO) ou à l'administrateur de l'application.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer(minLength: 24)
                    
                    // Bouton d'acceptation / confirmation
                    Button(action: {
                        SecureStorageService.shared.hasAcceptedLegalNotice = true
                        onAccept?()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("J'ai pris connaissance de mes droits et obligations")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 12)
                }
                .padding()
            }
            .navigationTitle("Information & Confidentialité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func bulletPoint(title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.blue)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(desc)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}
