//
//  EntryUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//


import Entities
import RepositoryProtocol
import UseCaseProtocol

public class EntryUseCase: EntryUseCaseProtocol {
    private var inboxRepo: InboxRepositoryProtocol
    private var entryRepo: EntryRepositoryProtocol
    private var fileRepo: FileRepositoryProtocol
    
    public init(inboxRepo: InboxRepositoryProtocol, entryRepo: EntryRepositoryProtocol, fileRepo: FileRepositoryProtocol) {
        self.inboxRepo = inboxRepo
        self.entryRepo = entryRepo
        self.fileRepo = fileRepo
    }
    
    public func quickInbox(url: String, fileName: String, fileType: Entities.FileType) throws {
        var opt = QuickInbox(sourceType: .Url, fileType: fileType, filename: fileName)
        opt.url = url
        try self.inboxRepo.QuickInbox(opt)
    }
    
    public func getEntryDetails(entry: Int64) throws -> any Entities.EntryDetail {
        return try entryRepo.GetEntryDetail(entry: entry)
    }
    
    public func renameEntry(entry: Int64, newName: String) throws {
        let en = try getEntryDetails(entry: entry)
        var opt = ChangeParentOption()
        opt.newName = newName
        return try entryRepo.ChangeParent(entry: en.id, newParent: en.parent, option: opt)
    }
    
    public func deleteEntry(entry: Int64) throws {
        try entryRepo.DeleteEntries(entrys: [entry])
    }
    
    public func deleteEntries(entries: [Int64]) throws {
        return try entryRepo.DeleteEntries(entrys: entries)
    }

    public func getTreeRoot() throws -> any Entities.Group {
        return try entryRepo.GroupTree()
    }
    
    public func listChildren(entry: Int64) throws -> [any Entities.EntryInfo] {
        return try entryRepo.ListGroupChildren(filter: EntryFilter(parent: entry))
    }
    
    public func changeParent(entry: Int64, newParent: Int64) throws {
        return try entryRepo.ChangeParent(entry: entry, newParent: newParent, option: ChangeParentOption())
    }
    
    public func createGroups(parent: Int64, option: Entities.EntryCreate) throws -> EntryInfo{
        var entry = EntryCreate(parent: parent, name: option.name, kind: option.kind)
        if let rssCfg = option.RSS{
            entry.RSS = rssCfg
        }
        return try entryRepo.CreateEntry(entry: entry)
    }
    
}
