//
//  FileRepository.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities
import NetworkCore
import RepositoryProtocol


public class FileRepository: FileRepositoryProtocol {
    
    private var core: FileClientProtocol
    
    public init(core: FileClientProtocol) {
        self.core = core
    }
    
    public func UploadFile(entry: Int64, fileHandle: FileHandle) async throws {
        return try await core.UploadFile(entry: entry, fileHandle: fileHandle)
    }
    
    public func DownloadFile(entry: Int64, dir: String) async throws -> String {
        let file = "\(dir)/en-\(entry)"
        let fileTmp = "\(dir)/en-\(entry).tmp"
        let fmanager = FileManager.default
        if fmanager.fileExists(atPath: fileTmp) {
            try fmanager.removeItem(atPath: fileTmp)
        }
        
        defer {
            do {
                try fmanager.removeItem(atPath: fileTmp)
            } catch {
                print("clean up tmp file failed \(error)")
            }
        }
        
        try await core.DownloadFile(entry: entry, file: fileTmp)
        try fmanager.moveItem(atPath: fileTmp, toPath: file)
        
        return file
    }
    
}
