//
//  FileClient.swift
//  Data
//
//  REST API implementation of File client
//

import os
import Foundation
import Entities
import NetworkCore

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
            .filesContent(uri: nil, id: entry),
            fileData: fileData,
            fileName: "file",
            mimeType: "application/octet-stream"
        )

        Self.logger.notice("upload file \(entry), len=\(fileData.count)")
    }

    public func DownloadFile(entry: Int64, file: String) async throws {
        guard let fileHandle = FileHandle(forWritingAtPath: file) else {
            throw BizError.openFileError
        }
        defer {
            fileHandle.closeFile()
        }

        let data = try await apiClient.requestData(.filesContent(uri: nil, id: entry))
        try fileHandle.write(contentsOf: data)
    }
}
