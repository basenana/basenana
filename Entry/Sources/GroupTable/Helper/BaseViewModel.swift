//
//  BaseViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/30.
//

import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class BaseViewModel {
    
    // tree store
    var groupTree = GroupTree.shared
    
    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol
    
    init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }
    
    func describeEntry(entry: Int64) async -> Entities.EntryDetail? {
        do {
            return try await entryUsecase.getEntryDetails(entry: entry)
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("describe entry failed: \(error)")
        }
        return nil
    }
    
    func getGroup(groupID: Int64) async -> Entities.Group? {
        do {
            let groupEntry = try await entryUsecase.getEntryDetails(entry: groupID)
            return groupEntry.toGroup()
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("get group failed: \(error)")
        }
        return nil
    }
    
    func moveEntriesToGroup(entryURLs: [URL], newParent: Int64) async -> Bool {
        var entries = [Int64]()
        var files = [URL]()
        
        for url in entryURLs {
            switch url.scheme {
            case "basenana":
                
                let targetID = parseEntryIDFromURL(url: url)
                guard targetID != nil && targetID! > 0 else {
                    sentAlert("\(url) not a valid entry")
                    return false
                }
                entries.append(targetID!)
                
            case "file":
                
                files.append(url)
                
            default:
                
                print("[moveEntriesAndUpdateTree] unknown url schema \(url)")
                return false
            }
        }
        
        if !entries.isEmpty {
            return await moveEntriesToGroup(entries: entries, newParent: newParent)
        }
        
        if !files.isEmpty {
            do {
                try await uploadFiles(parentID: newParent, files: files)
            } catch {
                sentAlert("upload files failed \(error)")
                return false
            }
            return true
        }
        
        return false
    }
    
    func moveEntriesToGroup(entries: [Int64], newParent: Int64) async -> Bool {
        do {
            try await entryUsecase.changeParent(entries: entries, newParent: newParent) { target, parent in
                if target.isGroup {
                    if let grp = GroupTree.shared.getGroup(groupID: target.id) {
                        GroupTree.shared.removeChildGroup(parentID: target.parent, childID: target.id)
                        GroupTree.shared.addChildGroup(parentID: parent.id, child: grp.group, grandChildren: grp.children)
                    }
                }
            }
            NotificationCenter.default.post(name: .reopenGroup, object: [newParent])
        } catch {
            sentAlert("move entry failed \(error)")
            return false
        }
        
        return false
    }
    
    func replicateEntryToGroup(entries: [Int64], newParent: Int64) {
        sentAlert("not support")
    }
    
    // MARK file upload/download
    func uploadFiles(parentID: Int64, files: [URL]) async throws  {
        for file in files {
            store.newBackgroundJob(
                name: "Uploading \(file.lastPathComponent)",
                job: {
                    Task {
                        if try file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                            throw BizError.isGroup
                        }
                        
                        var properties: [String:String] = [Property.LocalFile:file.path()]
                        do {
                            let en = try await self.entryUsecase.UploadFile(parent: parentID, file: file, properties: properties)
                            print("upload new entry \(en.id)/\(en.name)")
                        } catch {
                            sentAlert("upload file \(file.lastPathComponent) failed \(error)")
                        }
                    }
                },
                complete: {
                    NotificationCenter.default.post(name: .reopenGroup, object: [parentID])
                }
            )
        }
    }
}
