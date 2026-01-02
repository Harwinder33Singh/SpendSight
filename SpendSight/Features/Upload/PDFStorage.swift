//
//  PDFStorage.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import Foundation

enum PDFStorage {
    static func appPDFsDirectory() throws -> URL {
        let docs = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = docs.appendingPathComponent("ImportedPDFs", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    /// Copies a picked PDF into the app sandbox and returns the new URL.
    static func importPDF(from pickedURL: URL) throws -> URL {
        // If from Files/iCloud, we may need to access security scoped resource
        let didStartAccessing = pickedURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing { pickedURL.stopAccessingSecurityScopedResource() }
        }

        let targetDir = try appPDFsDirectory()

        // Make a unique filename to avoid collisions
        let baseName = pickedURL.deletingPathExtension().lastPathComponent
        let ext = pickedURL.pathExtension.isEmpty ? "pdf" : pickedURL.pathExtension

        var destination = targetDir.appendingPathComponent("\(baseName).\(ext)")
        var counter = 1
        while FileManager.default.fileExists(atPath: destination.path) {
            destination = targetDir.appendingPathComponent("\(baseName)-\(counter).\(ext)")
            counter += 1
        }

        // Copy file
        try FileManager.default.copyItem(at: pickedURL, to: destination)
        return destination
    }
}
