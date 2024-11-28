//
//  TrewViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class TreeViewModel {
    
    // tree store
    var groupTree = GroupTree.shared
    var groupState = GroupState.shared
    
    var showCreateGroup: Bool = false
    var createGroupInParent: Entities.Group = UnknownGroup.shared
    var createGroupType: GroupType = .standard
    
    var showQuickInbox: Bool = false

    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol

    public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }
    
    func resetGroupTree() async {
        print("[resetGroupTree] load and reset group root")
        do {
            self.groupTree.reset(root: try await entryUsecase.getTreeRoot())
        } catch {
            store.alert.display(msg: "load group tree failed: \(error)")
        }
    }
    
    // quick inbox
    func quickInbox(url: String, title: String, fileType: String, errorMsg: Binding<String>) async -> Bool {
        var safeFileType: Entities.FileType = .Webarchive
        switch fileType{
        case "html":
            safeFileType = .Html
        case "webarchive":
            safeFileType = .Webarchive
        default:
            safeFileType = .Webarchive
        }
        do {
            print("quick inbox url=\(url) fileName=\(title) fileType=\(safeFileType)")
            try await entryUsecase.quickInbox(url: url, fileName: sanitizeFileName(title), fileType: safeFileType)
        } catch {
            errorMsg.wrappedValue = "inbox failed: \(error)"
            return false
        }
        
        groupState.requestReopen()
        return true
    }
    
    func describeEntry(entry: Int64) async -> Entities.EntryDetail? {
        do {
            return try await entryUsecase.getEntryDetails(entry: entry)
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            store.alert.display(msg: "describe entry failed: \(error)")
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
            store.alert.display(msg: "get group failed: \(error)")
        }
        return nil
    }
    
    func moveEntriesToGroup(entryURLs: [URL], newParent: Int64) async -> Bool {
        var entries = [Int64]()
        var files = [Int64]()
        
        for url in entryURLs {
            switch url.scheme {
            case "basenana":
                
                let targetID = parseEntryIDFromURL(url: url)
                guard targetID != nil && targetID! > 0 else {
                    store.dispatch(.alert(msg: "\(url) not a valid entry"))
                    return false
                }
                entries.append(targetID!)
                
            case "file":
                
                print("[moveEntriesAndUpdateTree] upload file")
                return false
            default:
                
                print("[moveEntriesAndUpdateTree] unknown url schema \(url)")
                return false
            }
        }
        
        if !entries.isEmpty {
            return await moveEntriesToGroup(entries: entries, newParent: newParent)
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
            groupState.requestReopen()
        } catch {
            store.alert.display(msg: "move entry failed \(error)")
            return false
        }
        
        return false
    }
    
    func replicateEntryToGroup(entries: [Int64], newParent: Int64) {
        store.dispatch(.alert(msg: "not support"))
    }
}
