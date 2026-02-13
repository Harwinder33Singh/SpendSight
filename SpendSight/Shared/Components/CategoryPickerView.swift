//
//  CategoryPickerView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

struct CategoryPickerView: View {
    var categories: FetchedResults<Category>
    @Binding var selected: Category?
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories, id: \.objectID) { category in
                CategoryItemView(
                    name: category.name ?? "Unnamed",
                    icon: category.icon ?? "questionmark",
                    color: color(from: category.colorHex),
                    isSelected: selected?.objectID == category.objectID
                )
                .onTapGesture { withAnimation(.easeInOut(duration: 0.2))
                    {
                        selected = category
                    }
                    
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }.padding(.vertical, 4)
    }
}

struct CategoryItemView: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 24)
                .foregroundStyle(color)
            Text(name)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.body)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? color.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Helper Function

/// Converts a hex color string to SwiftUI Color
func color(from hex: String?) -> Color {
    guard let hex = hex else { return .blue }
    
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    
    guard Scanner(string: cleaned).scanHexInt64(&int) else { return .blue }
    
    let a, r, g, b: UInt64
    switch cleaned.count {
    case 6: // RGB
        (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
    case 8: // RGBA
        (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
        return .blue
    }
    
    return Color(
        .sRGB,
        red: Double(r) / 255,
        green: Double(g) / 255,
        blue: Double(b) / 255,
        opacity: Double(a) / 255
    )
}
