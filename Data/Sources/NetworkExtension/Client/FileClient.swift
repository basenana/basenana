//
//  FileClient.swift
//  Data
//
//  Created by Hypo on 2024/9/17.
//


import Entities
import NetworkCore
import Foundation


public class FileClient: FileClientProtocol {
    
    var client: Api_V1_EntriesClientProtocol
    
    init(client: Api_V1_EntriesClientProtocol) {
        self.client = client
    }
    
    public func WriteFile(entry: Int64, off: Int64, len: Int64, input: Stream) throws {
        throw RepositoryError.unimplement
    }
    
    public func ReadFile(entry: Int64, off: Int64, len: Int64) throws -> Stream {
        throw RepositoryError.unimplement
    }
    
}
