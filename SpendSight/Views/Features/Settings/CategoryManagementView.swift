//
//  CategoryManagementView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

struct CategoryManagementView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>

    @State private var showingAddCategory = false
    @State private var categoryToEdit: Category?
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(categories, id: \.objectID) { category in
                        CategoryRowView(category: category) {
                            categoryToEdit = category
                        } onDelete: {
                            categoryToDelete = category
                            showingDeleteAlert = true
                        }
                    }
                } header: {
                    HStack {
                        Text("Categories")
                        Spacer()
                        Text("\(categories.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button {
                        showingAddCategory = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Add New Category")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddEditCategoryView()
                    .environment(\.managedObjectContext, context)
            }
            .sheet(item: $categoryToEdit) { category in
                AddEditCategoryView(category: category)
                    .environment(\.managedObjectContext, context)
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    categoryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategory(category)
                    }
                    categoryToDelete = nil
                }
            } message: {
                if let category = categoryToDelete {
                    Text("Are you sure you want to delete '\(category.name ?? "Unknown")'? This action cannot be undone.")
                }
            }
        }
    }

    private func deleteCategory(_ category: Category) {
        withAnimation {
            context.delete(category)
            context.saveIfNeeded()
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: category.sfSymbol)
                .font(.title2)
                .foregroundStyle(category.color)
                .frame(width: 32, height: 32)

            // Category Info
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name ?? "Unknown")
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Text("\(category.transactionCount) transactions")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if category.hasBudget {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Budget: \(category.formattedBudget)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Edit button
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
    }
}

#Preview {
    CategoryManagementView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}