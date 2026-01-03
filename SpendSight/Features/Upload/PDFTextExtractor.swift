//
//  PDFTextExtractor.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import Foundation
import PDFKit
import Vision
import UIKit

enum PDFTextExtractor {

    /// 1) Try native PDF text extraction (best for digital statements)
    static func extractSelectableText(from url: URL) -> String? {
        guard let doc = PDFDocument(url: url) else { return nil }
        let text = doc.string ?? ""
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    /// 2) OCR fallback (for scanned PDFs)
    static func extractTextWithOCR(from url: URL) async throws -> String {
        guard let doc = PDFDocument(url: url) else { return "" }

        var combined = ""

        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i) else { continue }
            guard let image = render(page: page) else { continue }

            let pageText = try await ocr(image: image)

            combined += "\n--- PAGE \(i + 1) ---\n"
            combined += pageText
            combined += "\n"
        }

        return combined.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Render a PDF page into a UIImage for OCR
    private static func render(page: PDFPage) -> UIImage? {
        let bounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 2.0 // bump to 3.0 if OCR is weak (slower)
        let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: size))

            ctx.cgContext.saveGState()
            ctx.cgContext.translateBy(x: 0, y: size.height)
            ctx.cgContext.scaleBy(x: scale, y: -scale)

            page.draw(with: .mediaBox, to: ctx.cgContext)
            ctx.cgContext.restoreGState()
        }
    }

    // Vision OCR for a single image
    private static func ocr(image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return "" }

        return try await withCheckedThrowingContinuation { cont in
            let request = VNRecognizeTextRequest { req, err in
                if let err { cont.resume(throwing: err); return }

                let text = (req.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n") ?? ""

                cont.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.02
            request.recognitionLanguages = ["en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                cont.resume(throwing: error)
            }
        }
    }
}
