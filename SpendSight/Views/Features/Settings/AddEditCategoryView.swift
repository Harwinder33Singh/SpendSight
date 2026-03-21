//
//  AddEditCategoryView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

struct AddEditCategoryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    let category: Category?

    @State private var name: String = ""
    @State private var selectedColor: String = "#4CAF50"
    @State private var selectedIcon: String = "questionmark.circle.fill"
    @State private var monthlyBudget: String = ""
    @State private var hasBudget: Bool = false

    @State private var showingIconPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""

    private var isEditing: Bool {
        category != nil
    }

    init(category: Category? = nil) {
        self.category = category
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Category name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Icon")
                        Spacer()
                        Button {
                            showingIconPicker = true
                        } label: {
                            HStack {
                                Image(systemName: selectedIcon)
                                    .foregroundStyle(Color(hex: selectedColor) ?? .blue)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                        ColorPickerView(selectedColor: $selectedColor)
                    }
                }

                Section("Budget") {
                    Toggle("Set Monthly Budget", isOn: $hasBudget)

                    if hasBudget {
                        HStack {
                            Text("Amount")
                            Spacer()
                            TextField("0", text: $monthlyBudget)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundStyle(Color(hex: selectedColor) ?? .blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(name.isEmpty ? "Category Name" : name)
                                .font(.headline)

                            if hasBudget && !monthlyBudget.isEmpty {
                                if let budget = Double(monthlyBudget) {
                                    Text("Budget: \(formatCurrency(budget))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle(isEditing ? "Edit Category" : "Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Add") {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadCategoryData()
            }
        }
    }

    private func loadCategoryData() {
        guard let category = category else { return }

        name = category.name ?? ""
        selectedColor = category.colorHex ?? "#4CAF50"
        selectedIcon = category.icon ?? "questionmark.circle.fill"

        let budget = category.monthlyBudget
        if budget > 0 {
            hasBudget = true
            monthlyBudget = String(budget)
        } else {
            hasBudget = false
            monthlyBudget = ""
        }
    }

    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            errorMessage = "Category name cannot be empty"
            showingError = true
            return
        }

        let budgetValue = hasBudget ? (Double(monthlyBudget) ?? 0) : 0

        if isEditing {
            // Update existing category
            guard let category = category else { return }
            category.name = trimmedName
            category.colorHex = selectedColor
            category.icon = selectedIcon
            category.monthlyBudget = budgetValue
        } else {
            // Create new category
            let _ = Category(
                context: context,
                name: trimmedName,
                colorHex: selectedColor,
                icon: selectedIcon,
                monthlyBudget: budgetValue
            )
        }

        do {
            try context.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save category: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(amount)
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: String

    private let colors = [
        "#4CAF50", "#2196F3", "#FF9800", "#9C27B0", "#F44336",
        "#E91E63", "#795548", "#607D8B", "#FF5722", "#8BC34A",
        "#00ACC1", "#26A69A", "#7E57C2", "#FF6F00", "#6F4E37",
        "#3F51B5", "#9E9E9E", "#CDDC39", "#FFC107", "#673AB7"
    ]

    private let columns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(Color(hex: color) ?? .blue)
                        .frame(width: 40, height: 40)
                        .overlay {
                            if selectedColor == color {
                                Image(systemName: "checkmark")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.easeInOut(duration: 0.2), value: selectedColor)
            }
        }
    }
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    private let iconCategories = [
        ("Shopping", [
            "cart.fill", "bag.fill", "creditcard.and.123", "giftcard.fill",
            "basket.fill", "handbag.fill"
        ]),
        ("Food & Dining", [
            "cup.and.saucer.fill", "fork.knife", "birthday.cake.fill",
            "takeoutbag.and.cup.and.straw.fill", "wineglass.fill", "mug.fill"
        ]),
        ("Transportation", [
            "car.fill", "fuelpump.fill", "airplane", "bicycle",
            "bus.fill", "tram.fill"
        ]),
        ("Entertainment", [
            "film.fill", "tv.fill", "gamecontroller.fill", "music.note",
            "book.fill", "headphones"
        ]),
        ("Home & Utilities", [
            "house.fill", "bolt.fill", "wifi", "phone.fill",
            "bed.double.fill", "sofa.fill"
        ]),
        ("Health & Fitness", [
            "cross.case.fill", "heart.fill", "figure.walk", "dumbbell.fill",
            "stethoscope", "pills.fill"
        ]),
        ("Work & Education", [
            "briefcase.fill", "graduationcap.fill", "book.closed.fill",
            "pencil", "doc.text.fill", "laptopcomputer"
        ]),
        ("Finance", [
            "dollarsign.circle.fill", "banknote.fill", "chart.bar.fill",
            "chart.pie.fill", "percent", "building.columns.fill"
        ]),
        ("General", [
            "questionmark.circle.fill", "star.fill", "heart.circle.fill",
            "flag.fill", "tag.fill", "exclamationmark.triangle.fill"
        ])
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(iconCategories, id: \.0) { category, icons in
                    Section(category) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                    dismiss()
                                } label: {
                                    VStack {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundStyle(selectedIcon == icon ? .blue : .primary)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                Circle()
                                                    .fill(selectedIcon == icon ? .blue.opacity(0.1) : Color.clear)
                                            )

                                        if selectedIcon == icon {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddEditCategoryView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
