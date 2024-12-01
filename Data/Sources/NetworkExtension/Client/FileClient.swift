//
//  FileClient.swift
//  Data
//
//  Created by Hypo on 2024/9/17.
//

import GRPC
import Entities
import NetworkCore
import Foundation


public class FileClient: FileClientProtocol {
    
    var client: Api_V1_EntriesAsyncClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.entries
    }
    
    public func UploadFile(entry: Int64, fileHandle: FileHandle) async throws {
        let resp = try await client.writeFile(FileReader(entry: entry, fileHandle: fileHandle))
        print("upload file \(entry), len=\(resp.len)")
    }
    
    public func DownloadFile(entry: Int64, file: String) async throws {
        guard let fileHandle = FileHandle(forWritingAtPath: file) else {
            throw BizError.openFileError
        }
        defer {
            fileHandle.closeFile()
        }
        
        var req = Api_V1_ReadFileRequest()
        req.entryID = entry
        req.off = 0
        
        var stream = client.readFile(req).makeAsyncIterator()
        
        do {
            while let resp = try await stream.next() {
                if resp.data.isEmpty{
                    break
                }
                try fileHandle.write(contentsOf: resp.data)
            }
            
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
}


struct FileReader: AsyncSequence, AsyncIteratorProtocol {
    
    var entryID: Int64
    var fileHandle: FileHandle
    var off: Int64 = 0
    var finish: Bool = false
    
    init(entry: Int64, fileHandle: FileHandle) {
        self.entryID = entry
        self.fileHandle = fileHandle
    }
    
    mutating func next() async -> Api_V1_WriteFileRequest? {
        
        if finish {
            return nil
        }
        
        let data = fileHandle.readData(ofLength: 1024 * 1024 * 4)
        var req = Api_V1_WriteFileRequest()
        req.entryID = entryID
        req.off = off
        
        if data.isEmpty {
            finish = true
            return req
        }
        
        req.data = data
        req.len = Int64(data.count)
        off += req.len
        return req
    }
    
    func makeAsyncIterator() -> FileReader {
        self
    }
}

