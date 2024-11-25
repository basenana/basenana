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
    
    public func WriteFile(entry: Int64, off: Int64, len: Int64, input: Stream) async throws {
        return try await core.WriteFile(entry: entry, off: off, len: len, input: input)
    }
    
    public func ReadFile(entry: Int64, off: Int64, len: Int64) async throws -> Stream {
        return try await core.ReadFile(entry: entry, off: off, len: len)
    }
    
}
