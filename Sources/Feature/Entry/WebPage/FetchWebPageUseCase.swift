import Foundation
import os
import Domain
import SwiftSoup

public final class FetchWebPageUseCase: FetchWebPageUseCaseProtocol {
    private let entryUsecase: EntryUseCaseProtocol
    private let setting: GeneralSetting
    private let readability = ReadabilityExtractor()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.basenana", category: "FetchWebPageUseCase")

    public init(entryUsecase: EntryUseCaseProtocol, setting: GeneralSetting) {
        self.entryUsecase = entryUsecase
        self.setting = setting
    }

    public func execute(url: String, title: String?) async throws -> EntryInfo {
        guard let urlObj = URL(string: url) else {
            throw WebError.InvalidUrl(url)
        }

        let (data, response) = try await URLSession.shared.data(from: urlObj)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WebError.Unknown
        }

        guard let html = String(data: data, encoding: .utf8), !html.isEmpty else {
            throw WebError.BodyIsEmpty
        }

        // Use Readability-style extraction
        let readabilityResult = try readability.parse(html: html, url: url)
        let finalTitle = title ?? readabilityResult.title

        if setting.inboxFileType == "webarchive" {
            return try await saveWebArchive(url: urlObj, title: finalTitle, html: readabilityResult.content)
        } else {
            return try await saveHTML(url: urlObj, title: finalTitle, html: readabilityResult.content)
        }
    }

    private func saveWebArchive(url: URL, title: String, html: String) async throws -> EntryInfo {
        let tempDir = FileManager.default.temporaryDirectory
        let rawTitle = title.isEmpty ? "webpage" : title
        let sanitizedTitle = sanitizeFileName(rawTitle)
        let fileName = "\(sanitizedTitle).webarchive"
        let fileURL = tempDir.appendingPathComponent(fileName)

        logger.info("saveWebArchive: rawTitle='\(rawTitle)', sanitized='\(sanitizedTitle)', fileName='\(fileName)'")

        let plistData = try await createWebArchive(url: url, html: html, fileURL: fileURL)
        logger.info("Webarchive created, plistData size: \(plistData.count) bytes")

        // Verify file was written
        if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let size = attrs[.size] as? Int64 {
            logger.info("File size on disk: \(size) bytes")
        }

        let entry = try await entryUsecase.UploadFile(
            parentUri: EntryURI.inbox,
            file: fileURL,
            properties: ["url": url.absoluteString],
            tags: nil,
            document: DocumentCreate(title: title, url: url.absoluteString)
        )

        try? FileManager.default.removeItem(at: fileURL)
        logger.info("Uploaded webarchive: \(entry.id)/\(entry.name)")
        return entry
    }

    private func saveHTML(url: URL, title: String, html: String) async throws -> EntryInfo {
        let tempDir = FileManager.default.temporaryDirectory
        let rawTitle = title.isEmpty ? "webpage" : title
        let sanitizedTitle = sanitizeFileName(rawTitle)
        let fileName = "\(sanitizedTitle).html"
        let fileURL = tempDir.appendingPathComponent(fileName)

        logger.info("saveHTML: rawTitle='\(rawTitle)', sanitized='\(sanitizedTitle)', fileName='\(fileName)'")

        try html.write(to: fileURL, atomically: true, encoding: .utf8)

        // Verify file was written
        if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let size = attrs[.size] as? Int64 {
            logger.info("HTML file size on disk: \(size) bytes")
        }

        let entry = try await entryUsecase.UploadFile(
            parentUri: EntryURI.inbox,
            file: fileURL,
            properties: ["url": url.absoluteString],
            tags: nil,
            document: DocumentCreate(title: title, url: url.absoluteString)
        )

        try? FileManager.default.removeItem(at: fileURL)
        logger.info("Uploaded HTML: \(entry.id)/\(entry.name)")
        return entry
    }

    private func createWebArchive(url: URL, html: String, fileURL: URL) async throws -> Data {
        logger.info("createWebArchive: url=\(url), htmlSize=\(html.count) bytes")

        return try await withCheckedThrowingContinuation { continuation in
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try? FileManager.default.removeItem(at: fileURL)
            }
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            self.logger.info("Created empty file: \(fileURL.path)")

            do {
                let fh = try FileHandle(forWritingTo: fileURL)
                WebArchiver.archiveWithMainResource(url: url, htmlContent: html) { result in
                    self.logger.info("WebArchiver callback: errors=\(!result.errors.isEmpty), plistData=\(result.plistData?.count ?? 0) bytes")
                    defer { try? fh.close() }
                    if !result.errors.isEmpty {
                        self.logger.error("WebArchiver errors: \(result.errors.first!.localizedDescription)")
                        continuation.resume(throwing: result.errors.first!)
                    } else if let plistData = result.plistData {
                        do {
                            try fh.write(contentsOf: plistData)
                            self.logger.info("Wrote \(plistData.count) bytes to file")
                            continuation.resume(returning: plistData)
                        } catch {
                            self.logger.error("Write error: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                        }
                    } else {
                        self.logger.error("No plistData returned")
                        continuation.resume(throwing: WebError.InvalidPath)
                    }
                }
            } catch {
                self.logger.error("FileHandle error: \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
        }
    }
}
