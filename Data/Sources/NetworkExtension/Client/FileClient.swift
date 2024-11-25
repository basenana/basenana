//
//  FileClient.swift
//  Data
//
//  Created by Hypo on 2024/9/17.
//


import Entities
import NetworkCore
import Foundation


@available(macOS 11.0, *)
public class FileClient: FileClientProtocol {
    
    var client: Api_V1_EntriesAsyncClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.entries
    }
    
    public func WriteFile(entry: Int64, off: Int64, len: Int64, input: Stream) async throws {
        throw RepositoryError.unimplement
    }
    
    public func ReadFile(entry: Int64, off: Int64, len: Int64) async throws -> Stream {
        throw RepositoryError.unimplement
    }
    
}
