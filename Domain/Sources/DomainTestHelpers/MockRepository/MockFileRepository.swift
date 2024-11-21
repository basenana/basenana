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
    
    public func WriteFile(entry: Int64, off: Int64, len: Int64, input: Stream) throws {
        throw RepositoryError.unimplement
    }
    
    public func ReadFile(entry: Int64, off: Int64, len: Int64) throws -> Stream {
        throw RepositoryError.unimplement
    }
}

