//
//  FileRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol FileRepositoryProtocol {
    func UploadFile(entry: Int64, file: String) async throws
    func DownloadFile(entry: Int64, dir: String) async throws -> String
}
