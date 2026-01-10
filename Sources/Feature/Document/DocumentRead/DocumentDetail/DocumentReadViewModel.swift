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
        let documentsDir = cachesDir.appendingPathComponent("documents", isDirectory: true)

        let fm = FileManager.default
        if !fm.fileExists(atPath: documentsDir.path) {
            try? fm.createDirectory(at: documentsDir, withIntermediateDirectories: true)
        }

        return documentsDir
    }

    private func cachedFileURL(for entryId: Int64) -> URL {
        cacheDirectory.appendingPathComponent("en-\(entryId)")
    }

    func loadDocument() async {
        isLoading = true
        errorMessage = nil

        Self.logger.info("loadDocument: start for uri=\(self.uri)")

        do {
            guard let entryDetail = try await usecase.getDocumentEntry(uri: uri) else {
                Self.logger.error("loadDocument: getDocumentEntry returned nil")
                errorMessage = "Failed to load document"
                isLoading = false
                return
            }

            Self.logger.info("loadDocument: got entryDetail, id=\(entryDetail.id)")

            entry = entryDetail

            let fileURL = cachedFileURL(for: entryDetail.id)
            Self.logger.info("loadDocument: cache file path=\(fileURL.path)")

            if FileManager.default.fileExists(atPath: fileURL.path) {
                Self.logger.info("loadDocument: file already cached")
                cachedFileURL = fileURL
            } else {
                Self.logger.info("loadDocument: file not cached, downloading...")
                do {
                    _ = try await fileRepository.DownloadFile(entry: entryDetail.id, dir: cacheDirectory.path)
                    Self.logger.info("loadDocument: download completed")
                    cachedFileURL = fileURL
                } catch {
                    Self.logger.error("loadDocument: download failed, error=\(error.localizedDescription)")
                    errorMessage = "Download failed: \(error.localizedDescription)"
                }
            }
        } catch {
            Self.logger.error("loadDocument: error=\(error.localizedDescription)")
            errorMessage = "Load document failed: \(error.localizedDescription)"
        }

        isLoading = false
        Self.logger.info("loadDocument: finished, isLoading=\(self.isLoading), hasError=\(self.errorMessage != nil)")
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
