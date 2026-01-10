//
//  DocumentReadViewModel.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//

import os
import SwiftUI
import Foundation
import Domain

@Observable
@MainActor
public class DocumentReadViewModel {
    var uri: String
    var store: StateStore
    var usecase: any DocumentUseCaseProtocol
    var fileRepository: FileRepositoryProtocol
    var entry: EntryDetail? = nil
    var isLoading: Bool = false
    var cachedFileURL: URL?
    var errorMessage: String?

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: DocumentReadViewModel.self)
        )

    public init(
        uri: String,
        store: StateStore,
        usecase: any DocumentUseCaseProtocol,
        fileRepository: FileRepositoryProtocol
    ) {
        self.uri = uri
        self.store = store
        self.usecase = usecase
        self.fileRepository = fileRepository
    }

    private var cacheDirectory: URL {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let documentsDir = cachesDir.appendingPathComponent("nanafs", isDirectory: true)
            .appendingPathComponent("documents", isDirectory: true)

        let fm = FileManager.default
        if !fm.fileExists(atPath: documentsDir.path) {
            try? fm.createDirectory(at: documentsDir, withIntermediateDirectories: true)
        }

        return documentsDir
    }

    private func cachedFileURL(for entryId: Int64, name: String) -> URL {
        let ext = (name as NSString).pathExtension
        let baseName = ext.isEmpty ? "\(entryId)" : "\(entryId).\(ext)"
        return cacheDirectory.appendingPathComponent(baseName)
    }

    func loadDocument() async {
        isLoading = true
        errorMessage = nil

        Self.logger.info("loadDocument: uri=\(self.uri)")

        do {
            guard let entryDetail = try await usecase.getDocumentEntry(uri: uri) else {
                Self.logger.error("getDocumentEntry returned nil")
                errorMessage = "Failed to load document"
                isLoading = false
                return
            }

            Self.logger.info("entryDetail id=\(entryDetail.id), name=\(entryDetail.name)")
            entry = entryDetail
            let fileURL = cachedFileURL(for: entryDetail.id, name: entryDetail.name)

            if FileManager.default.fileExists(atPath: fileURL.path) {
                Self.logger.info("file already cached")
                cachedFileURL = fileURL
            } else {
                Self.logger.info("downloading...")
                do {
                    print("[DocumentReadViewModel] cacheDirectory=\(cacheDirectory.path)")
                    let resultPath = try await fileRepository.DownloadFile(entry: entryDetail.id, name: entryDetail.name, dir: cacheDirectory.path)
                    print("[DocumentReadViewModel] download result=\(resultPath)")

                    // Verify file exists and has content
                    let fm = FileManager.default
                    if fm.fileExists(atPath: fileURL.path) {
                        if let attrs = try? fm.attributesOfItem(atPath: fileURL.path),
                           let size = attrs[.size] as? Int64 {
                            print("[DocumentReadViewModel] file size=\(size)")
                        }
                    }
                    Self.logger.info("download completed")
                    cachedFileURL = fileURL
                } catch {
                    Self.logger.error("download failed: \(error.localizedDescription)")
                    errorMessage = "Download failed"
                }
            }
        } catch {
            Self.logger.error("error: \(error.localizedDescription)")
            errorMessage = "Load document failed"
        }

        isLoading = false
    }

    var targetURL: URL? {
        get {
            if let pro = getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL]) {
                if let u = URL(string: pro.value) {
                    return u
                }
            }
            return nil
        }
    }

    func getEntryProperty(keys: [String]) -> EntryProperty? {
        guard entry != nil else {
            return nil
        }
        for k in keys {
            for p in entry!.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}
