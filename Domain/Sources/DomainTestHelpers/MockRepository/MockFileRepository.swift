//  MockFileRepository.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import SwiftUI
import Entities
import RepositoryProtocol


public class MockFileRepository: FileRepositoryProtocol {
    
    public static var shared = MockFileRepository()
    
    init() { }
    
    public func UploadFile(entry: Int64, file: String) async throws {
        throw RepositoryError.unimplement
    }
    
    public func DownloadFile(entry: Int64, dir: String) async throws -> String {
        throw RepositoryError.unimplement
    }
}

