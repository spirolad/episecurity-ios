//
//  UserManagementView.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import SwiftUI

public struct UserManagementView: View {
    @StateObject private var viewModel = UserManagementViewModel()
    @State private var userToDelete: User?
    @State private var showDeleteConfirmation = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Barre de recherche
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Rechercher un utilisateur...", text: $viewModel.searchText)
                    }
                    .padding(10)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Filtre par rôle
                    Picker("Rôle", selection: $viewModel.selectedRoleFilter) {
                        Text("Tous").tag(Role?.none)
                        Text("Salariés").tag(Role?.some(.employee))
                        Text("Managers").tag(Role?.some(.manager))
                        Text("Admins").tag(Role?.some(.admin))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    if viewModel.isLoading && viewModel.users.isEmpty {
                        LoadingView(message: "Chargement de l'annuaire...")
                    } else {
                        List {
                            ForEach(viewModel.filteredUsers) { user in
                                userRow(for: user)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            await viewModel.loadUsers()
                        }
                    }
                }
            }
            .navigationTitle("Gestion des comptes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showCreateUserSheet = true
                    }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateUserSheet) {
                createUserSheet
            }
            .sheet(isPresented: $viewModel.showAssignManagerSheet) {
                assignManagerSheet
            }
            .confirmationDialog(
                "Supprimer l'utilisateur",
                isPresented: $showDeleteConfirmation,
                presenting: userToDelete
            ) { user in
                Button("Supprimer", role: .destructive) {
                    Task {
                        await viewModel.deleteUser(user: user)
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: { user in
                Text("Voulez-vous vraiment supprimer définitivement le compte de \(user.fullName) ?")
            }
            .task {
                await viewModel.loadUsers()
            }
        }
    }
    
    private func userRow(for user: User) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(user.role.badgeColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(user.initials)
                    .font(.subheadline.bold())
                    .foregroundColor(user.role.badgeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.fullName)
                        .font(.headline)
                    Spacer()
                    BadgeView(role: user.role)
                }
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if user.role == .employee {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(user.managerName != nil ? "Manager : \(user.managerName!)" : "Aucun manager affecté")
                            .font(.caption2)
                            .foregroundColor(user.managerName != nil ? .primary : .orange)
                    }
                    .padding(.top, 2)
                }
            }
            
            // Menu d'actions d'administration
            Menu {
                Menu("Modifier le rôle") {
                    ForEach(Role.allCases) { role in
                        Button(action: {
                            Task {
                                await viewModel.updateUserRole(user: user, newRole: role)
                            }
                        }) {
                            HStack {
                                Text(role.displayName)
                                if user.role == role {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                
                if user.role == .employee {
                    Button(action: {
                        viewModel.selectedUserForAssignment = user
                        viewModel.selectedManagerId = user.managerId
                        viewModel.showAssignManagerSheet = true
                    }) {
                        Label("Affecter à un manager", systemImage: "person.2.badge.gearshape")
                    }
                }
                
                Divider()
                
                Button(role: .destructive, action: {
                    userToDelete = user
                    showDeleteConfirmation = true
                }) {
                    Label("Supprimer le compte", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var createUserSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations du profil")) {
                    TextField("Identifiant (ex: cdupond)", text: $viewModel.newUsername)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Nom complet (ex: Claire Dupond)", text: $viewModel.newFullName)
                    SecureField("Mot de passe initial", text: $viewModel.newPassword)
                }
                
                Section(header: Text("Rôle de l'utilisateur")) {
                    Picker("Rôle", selection: $viewModel.newRole) {
                        ForEach(Role.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.createUser()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Enregistrer l'utilisateur")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Créer un compte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.showCreateUserSheet = false
                    }
                }
            }
        }
    }
    
    private var assignManagerSheet: some View {
        NavigationView {
            Form {
                if let employee = viewModel.selectedUserForAssignment {
                    Section(header: Text("Salarié sélectionné")) {
                        Text(employee.fullName)
                            .font(.headline)
                        Text("@\(employee.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Section(header: Text("Sélectionner un manager")) {
                        Button(action: {
                            viewModel.selectedManagerId = nil
                        }) {
                            HStack {
                                Text("Aucun manager (Désaffecter)")
                                Spacer()
                                if viewModel.selectedManagerId == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        ForEach(viewModel.managers) { manager in
                            Button(action: {
                                viewModel.selectedManagerId = manager.id
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(manager.fullName)
                                            .foregroundColor(.primary)
                                        Text("@\(manager.username)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if viewModel.selectedManagerId == manager.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button(action: {
                            Task {
                                await viewModel.assignManager(
                                    employee: employee,
                                    managerId: viewModel.selectedManagerId
                                )
                            }
                        }) {
                            Text("Valider l'affectation")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Affectation Équipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.showAssignManagerSheet = false
                    }
                }
            }
        }
    }
}
