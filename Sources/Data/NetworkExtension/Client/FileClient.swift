//
//  FileClient.swift
//  Data
//
//  REST API implementation of File client
//

import os
import Foundation
import Domain
import Data

public class FileClient: FileClientProtocol {

    private let apiClient: APIClient

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FileClient.self)
    )

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func UploadFile(entry: Int64, fileHandle: FileHandle) async throws {
        let fileData = try fileHandle.readToEnd() ?? Data()

        _ = try await apiClient.uploadFile(
            .filesUpload(id: entry),
            fileData: fileData,
            fileName: "file",
            mimeType: "application/octet-stream"
        )

        Self.logger.notice("upload file \(entry), len=\(fileData.count)")
    }

    public func DownloadFile(entry: Int64, file: String) async throws {
        print("[FileClient] entry=\(entry), file=\(file)")

        // Check if parent directory exists
        let parentDir = (file as NSString).deletingLastPathComponent
        let fm = FileManager.default
        print("[FileClient] parentDir=\(parentDir)")
        print("[FileClient] parent exists=\(fm.fileExists(atPath: parentDir))")

        // Create file if it doesn't exist (FileHandle requires file to exist)
        if !fm.fileExists(atPath: file) {
            print("[FileClient] creating file: \(file)")
            fm.createFile(atPath: file, contents: nil, attributes: nil)
        }

        guard let fileHandle = FileHandle(forWritingAtPath: file) else {
            print("[FileClient] ERROR: failed to create file handle for \(file)")
            Self.logger.error("failed to create file handle")
            throw BizError.openFileError
        }
        defer {
            fileHandle.closeFile()
        }

        do {
            let data = try await apiClient.requestData(.filesContent(id: entry))
            try fileHandle.write(contentsOf: data)
        } catch {
            Self.logger.error("download failed: \(error.localizedDescription)")
            throw error
        }
    }
}
