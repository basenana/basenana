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
    
    public func quickInbox(url: String, fileName: String, fileType: Entities.FileType) async throws {
        var opt = QuickInbox(sourceType: .Url, fileType: fileType, filename: fileName)
        opt.url = url
        do {
            try await self.inboxRepo.QuickInbox(opt)
        } catch RepositoryError.canceled {
            return
        }
    }
    
    public func getEntryDetails(entry: Int64) async throws -> any Entities.EntryDetail {
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
        do {
            try await entryRepo.DeleteEntries(entrys: [entry])
        } catch RepositoryError.canceled {
            return
        }
    }
    
    public func deleteEntries(entries: [Int64]) async throws {
        do {
            return try await entryRepo.DeleteEntries(entrys: entries)
        } catch RepositoryError.canceled {
            return
        }
    }
    
    public func getTreeRoot() async throws -> any Entities.Group {
        do {
            return try await entryRepo.GroupTree()
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func listChildren(entry: Int64) async throws -> [any Entities.EntryInfo] {
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
                finisher(entry, parent)
            }
            
        } catch RepositoryError.canceled {
            return
        }
    }
    
    public func createGroups(parent: Int64, option: Entities.EntryCreate) async throws -> EntryInfo{
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
    
    public func UploadFile(parent: Int64, filePath: String) async throws -> EntryInfo {
        throw UseCaseError.unimplement
    }
    
    public func DownloadFile(entry: Int64, dirPath: String) async throws -> String {
        throw UseCaseError.unimplement
    }
}
