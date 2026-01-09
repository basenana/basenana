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
    
    public func getEntryDetails(uri: String) async throws -> any  EntryDetail {
        do {
            return try await entryRepo.GetEntryDetail(uri: uri)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func renameEntry(uri: String, newName: String) async throws {
        do {
            let en = try await getEntryDetails(uri: uri)
            var opt = ChangeParentOption()
            opt.newName = newName
            return try await entryRepo.ChangeParent(uri: uri, newParentUri: en.uri, option: opt)
        } catch RepositoryError.canceled {
            return
        }
    }

    public func deleteEntry(uri: String) async throws {
        let entryDetail = try await entryRepo.GetEntryDetail(uri: uri)
        if !entryDetail.isGroup{
            return try await entryRepo.DeleteEntries(uris: [uri])
        }

        let children = try await listChildren(uri: uri)
        for child in children {
            try await deleteEntry(uri: child.uri)
        }

        return try await entryRepo.DeleteEntries(uris: [uri])
    }

    public func deleteEntries(uris: [String]) async throws {
        for uri in uris {
            try await deleteEntry(uri: uri)
        }
    }
    
    public func getTreeRoot() async throws -> any  EntryGroup {
        do {
            return try await entryRepo.GroupTree()
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func listChildren(uri: String) async throws -> [any  EntryInfo] {
        do {
            return try await entryRepo.ListGroupChildren(parentUri: uri)
        } catch RepositoryError.canceled {
            return []
        }
    }

    public func changeParent(uris: [String], newParentUri: String, finisher: @escaping (EntryDetail, EntryDetail) -> Void) async throws {
        do {
            let parent = try await getEntryDetails(uri: newParentUri)
            if !parent.isGroup {
                throw BizError.notGroup
            }

            for uri in uris {
                let entry = try await getEntryDetails(uri: uri)
                try await entryRepo.ChangeParent(uri: uri, newParentUri: newParentUri, option: ChangeParentOption())
                DispatchQueue.main.async {
                    finisher(entry, parent)
                }
            }

        } catch RepositoryError.canceled {
            return
        }
    }

    public func createGroups(parentUri: String, option:  EntryCreate) async throws -> EntryInfo{
        var entry = EntryCreate(parentUri: parentUri, name: option.name, kind: option.kind)
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

        let option = EntryCreate(parentUri: "/\(parent)", name: file.lastPathComponent, kind: "raw")
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
