//
//  AccountPickerView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//
import SwiftUI
import CoreData

struct AccountPickerView: View {
    var accounts: FetchedResults<Account>
    @Binding var selected: Account?
    var onSelectionChanged: (Account?) -> Void = { _ in }
    
    var body: some View {
        Picker("Select Account", selection: Binding(
            get: {
                selected?.objectID
            },
            set: { newObjectID in
                if let objectID = newObjectID {
                    selected = accounts.first(where: { $0.objectID == objectID })
                } else {
                    selected = nil
                }
                onSelectionChanged(selected)
            }
        )) {
            // Placeholder option
            Text("Choose an account...").tag(nil as NSManagedObjectID?)
            
            // Account options
            ForEach(accounts, id: \.objectID) { account in
                HStack {
                    // Account icon based on type
                    Image(systemName: account.iconName)
                    
                    // Account display name
                    Text(account.displayName)
                    
                    // Show last 4 if available
                    if let last4 = account.formattedLast4 {
                        Text(last4)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tag(account.objectID as NSManagedObjectID?)
            }
        }
        .pickerStyle(.menu)
    }
}
