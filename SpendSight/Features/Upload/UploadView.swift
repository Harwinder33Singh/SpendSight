//
//  UploadView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct UploadView: View {
    // PDF Import
    @State private var showPicker = false
    @State private var importedPDFURL: URL?
    @State private var errorMessage: String?
    
    // Scan + OCR
    @State private var isExtracting = false
    @State private var extractedText: String = ""
    @State private var extractError: String?
    
    
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
                
                // SCAN + OCR
                Button {
                    guard let url = importedPDFURL else {
                        extractError = "Import a PDF first."
                        return
                    }
                    Task {
                        isExtracting = true
                        extractError = nil
                        errorMessage = nil
                        extractedText = ""
                        
                        // 1) Try selectable text first
                        if let text = PDFTextExtractor.extractSelectableText(from: url) {
                            extractedText = text
                            isExtracting = false
                            return
                        }
                        
                        // 2) Fallback to OCR
                        do {
                            extractedText = try await PDFTextExtractor.extractTextWithOCR(from: url)
                        } catch {
                            extractError = error.localizedDescription
                        }
                        
                        isExtracting = false
                    }
                } label: {
                    Label("Extract Text from PDF", systemImage: "text.viewfinder")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .disabled(importedPDFURL == nil)
                
                if isExtracting {
                    ProgressView("Extracting Text...")
                        .padding(.top, 4)
                }
                
                if let extractError {
                    Text("extract error: \(extractError)")
                        .foregroundStyle(.red)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                
                if !extractedText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Extracted Text")
                                .font(.headline)
                            Spacer()
                            Button("Copy") {
                                UIPasteboard.general.string = extractedText
                            }
                        }
                        
                        ScrollView {
                            Text(extractedText)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 220)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
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
                        Task {
                            do {
                                let savedURL = try PDFStorage.importPDF(from: pickedURL)
                                importedPDFURL = savedURL
                                errorMessage = nil
                                
                                // Optional: auto-extract immediately after import
                                isExtracting = true
                                extractedText = ""
                                extractError = nil
                                if let text = PDFTextExtractor.extractSelectableText(from: savedURL) {
                                    extractedText = text
                                } else {
                                    extractedText = try await PDFTextExtractor.extractTextWithOCR(from: savedURL)
                                }
                                isExtracting = false
                            } catch {
                                errorMessage = "Failed to import PDF: \(error.localizedDescription)"
                            }
                            showPicker = false
                        }
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
