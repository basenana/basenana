//
//  FileRepository.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import os
import Foundation
import Domain
import Data


public class FileRepository: FileRepositoryProtocol {
    
    private var core: FileClientProtocol
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: FileRepository.self)
        )
    
    public init(core: FileClientProtocol) {
        self.core = core
    }
    
    public func UploadFile(entry: Int64, fileHandle: FileHandle) async throws {
        Self.logger.info("FileRepository.UploadFile called for entry \(entry)")
        return try await core.UploadFile(entry: entry, fileHandle: fileHandle)
    }
    
    public func DownloadFile(entry: Int64, name: String, dir: String) async throws -> String {
        let ext = (name as NSString).pathExtension
        let baseName = ext.isEmpty ? "\(entry)" : "\(entry).\(ext)"
        let file = "\(dir)/\(baseName)"
        let fileTmp = "\(dir)/\(baseName).tmp"
        let fmanager = FileManager.default

        print("[FileRepository] dir=\(dir)")
        print("[FileRepository] name=\(name)")
        print("[FileRepository] ext=\(ext)")
        print("[FileRepository] file=\(file)")
        print("[FileRepository] fileTmp=\(fileTmp)")

        // Ensure directory exists
        if !fmanager.fileExists(atPath: dir) {
            print("[FileRepository] creating directory")
            try fmanager.createDirectory(atPath: dir, withIntermediateDirectories: true)
        } else {
            print("[FileRepository] directory exists")
        }

        // Clean up any existing temp file before download
        if fmanager.fileExists(atPath: fileTmp) {
            print("[FileRepository] removing existing tmp file")
            try fmanager.removeItem(atPath: fileTmp)
        }

        try await core.DownloadFile(entry: entry, file: fileTmp)
        try fmanager.moveItem(atPath: fileTmp, toPath: file)

        return file
    }
    
}
