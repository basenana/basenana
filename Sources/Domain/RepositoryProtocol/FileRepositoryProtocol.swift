//
//  FileRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation



public protocol FileRepositoryProtocol {
    func UploadFile(entry: Int64, fileHandle: FileHandle) async throws
    func DownloadFile(entry: Int64, name: String, dir: String) async throws -> String
}
