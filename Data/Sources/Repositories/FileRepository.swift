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
    
    init(core: FileClientProtocol) {
        self.core = core
    }
    
    public func WriteFile(entry: Int64, off: Int64, len: Int64, input: Stream) throws {
        return try core.WriteFile(entry: entry, off: off, len: len, input: input)
    }
    
    public func ReadFile(entry: Int64, off: Int64, len: Int64) throws -> Stream {
        return try core.ReadFile(entry: entry, off: off, len: len)
    }
    
}
