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
    public enum DocumentFileType {
        case html
        case pdf
        case markdown
    }

    var uri: String
    var store: StateStore
    var usecase: any DocumentUseCaseProtocol
    var fileRepository: FileRepositoryProtocol
    var entry: EntryDetail? = nil
    var isLoading: Bool = false
    var cachedFileURL: URL?
    var errorMessage: String?
    var fileType: DocumentFileType = .html

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
        let ext = (name as NSString).pathExtension.lowercased()
        let baseName = ext.isEmpty ? "\(entryId)" : "\(entryId).\(ext)"
        let url = cacheDirectory.appendingPathComponent(baseName)

        switch ext {
        case "pdf":
            fileType = .pdf
        case "md", "markdown":
            fileType = .markdown
        default:
            fileType = .html
        }

        return url
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
                    let resultPath = try await fileRepository.DownloadFile(entry: entryDetail.id, name: entryDetail.name, dir: cacheDirectory.path)
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

    func setDocumentReadStatus(isUnread: Bool) async {
        guard let entry = entry else { return }
        do {
            try await usecase.setDocumentReadState(uri: entry.uri, unread: isUnread)
        } catch {
            Self.logger.error("set read status failed: \(error.localizedDescription)")
        }
    }

    func setDocumentMarkStatus(isMarked: Bool) async {
        guard let entry = entry else { return }
        do {
            try await usecase.setDocumentMarkState(uri: entry.uri, ismark: isMarked)
        } catch {
            Self.logger.error("set mark status failed: \(error.localizedDescription)")
        }
    }
}
