//
//  EntryUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

import os
import Foundation



public class EntryUseCase: EntryUseCaseProtocol {
    
    private var entryRepo: EntryRepositoryProtocol
    private var fileRepo: FileRepositoryProtocol
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: EntryUseCase.self)
        )
    
    public init(entryRepo: EntryRepositoryProtocol, fileRepo: FileRepositoryProtocol) {
        self.entryRepo = entryRepo
        self.fileRepo = fileRepo
    }
    
    public func getEntryDetails(entry: Int64) async throws -> any  EntryDetail {
        do {
            return try await entryRepo.GetEntryDetail(entry: entry)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func renameEntry(entry: Int64, newName: String) async throws {
        do {
            let en = try await getEntryDetails(entry: entry)
            var opt = ChangeParentOption()
            opt.newName = newName
            return try await entryRepo.ChangeParent(entry: en.id, newParent: en.parent, option: opt)
        } catch RepositoryError.canceled {
            return
        }
    }
    
    public func deleteEntry(entry: Int64) async throws {
        let entryDetail = try await entryRepo.GetEntryDetail(entry: entry)
        if !entryDetail.isGroup{
            return try await entryRepo.DeleteEntries(entrys: [entry])
        }
        
        let children = try await listChildren(entry: entry)
        for child in children {
            try await deleteEntry(entry: child.id)
        }
        
        return try await entryRepo.DeleteEntries(entrys: [entry])
    }
    
    public func deleteEntries(entries: [Int64]) async throws {
        for entry in entries {
            try await deleteEntry(entry: entry)
        }
    }
    
    public func getTreeRoot() async throws -> any  EntryGroup {
        do {
            return try await entryRepo.GroupTree()
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func listChildren(entry: Int64) async throws -> [any  EntryInfo] {
        do {
            return try await entryRepo.ListGroupChildren(filter: EntryFilter(parent: entry))
        } catch RepositoryError.canceled {
            return []
        }
    }
    
    public func changeParent(entries: [Int64], newParent: Int64, finisher: @escaping (EntryDetail, EntryDetail) -> Void) async throws {
        do {
            let parent = try await getEntryDetails(entry: newParent)
            if !parent.isGroup {
                throw BizError.notGroup
            }
            
            for eid in entries {
                let entry = try await getEntryDetails(entry: eid)
                try await entryRepo.ChangeParent(entry: eid, newParent: newParent, option: ChangeParentOption())
                DispatchQueue.main.async {
                    finisher(entry, parent)
                }
            }
            
        } catch RepositoryError.canceled {
            return
        }
    }
    
    public func createGroups(parent: Int64, option:  EntryCreate) async throws -> EntryInfo{
        var entry = EntryCreate(parent: parent, name: option.name, kind: option.kind)
        if let rssCfg = option.RSS{
            entry.RSS = rssCfg
        }
        do {
            return try await entryRepo.CreateEntry(entry: entry)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func UploadFile(parent: Int64, file: URL, properties: [String:String] = [:]) async throws -> EntryInfo {
        let fileHandle = try FileHandle(forReadingFrom: file)
        defer {
            fileHandle.closeFile()
        }
        
        let option = EntryCreate(parent: parent, name: file.lastPathComponent, kind: "raw")
        let entry = try await entryRepo.CreateEntry(entry: option)
        Self.logger.info("create entry \(entry.id) for upload")
        
        for kv in properties {
            try await entryRepo.AddProperty(entry: entry.id, key: kv.key, val: kv.value)
        }
        
        try await fileRepo.UploadFile(entry: entry.id, fileHandle: fileHandle)
        return entry
    }
    
    public func DownloadFile(entry: Int64, dirPath: String) async throws -> String {
        throw UseCaseError.unimplement
    }
}
