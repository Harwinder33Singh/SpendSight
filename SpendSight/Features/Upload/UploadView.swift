//
//  UploadView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct UploadView: View {
    @State private var showPicker = false
    @State private var importedPDFURL: URL?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 16){
                Text("Upload Statements")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Button {
                    showPicker = true
                } label: {
                    Label("Import PDF", systemImage: "doc.fill.badge.plus")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                
                if let url = importedPDFURL {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Imported: ")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(url.lastPathComponent)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    
                    NavigationLink{
                        PDFKitView(url: url)
                            .navigationTitle(url.lastPathComponent)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Open PDF", systemImage: "doc.text.magnifyingglass")
                    }
                    .buttonStyle(.bordered)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Upload")
            .sheet(isPresented: $showPicker) {
                PDFDocumentPicker(
                    onPick: { pickedURL in
                        do {
                            let savedURL = try PDFStorage.importPDF(from: pickedURL)
                            importedPDFURL = savedURL
                            importedPDFURL = savedURL
                        } catch {
                            errorMessage = "Failed to import PDF: \(error.localizedDescription)"
                        }
                        showPicker = false
                    },
                    onCancel: {
                        showPicker = false
                    }
                )
            }
        }
    }
}

#Preview {
    UploadView()
}
