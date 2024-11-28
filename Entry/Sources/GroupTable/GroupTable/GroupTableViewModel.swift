//
//  GroupTableViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/27.
//

import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class GroupTableViewModel {
    
    var group: EntryDetail? = nil
    var children: [EntryRow] = []
    var inspectedDetails: [Int64:EntryDetail] = [:]
    
    var showCreateGroup: Bool = false
    var createGroupType: GroupType = .standard
    
    var showDeleteConfirm: Bool = false
    var showRenameEntry: Bool = false
    
    var selection: Set<EntryRow.ID> = []
    var selectedDocument: DocumentDetail? = nil
    
    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol
    
    public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }
    
    var selectedEntries: [EntryInfo] {
        get {
            children.filter( { selection.contains($0.id)} ).map({ $0.info })
        }
    }
    
    func openGroup(groupID: Int64) async {
        do {
            group = try await entryUsecase.getEntryDetails(entry: groupID)
            if group == nil || !group!.isGroup {
                throw BizError.notGroup
            }
            
            self.children = []
            let newChildren = try await entryUsecase.listChildren(entry: groupID)
            for child in newChildren {
                self.children.append(EntryRow(info: child))
            }
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            store.alert.display(msg: "open group failed: \(error)")
        }
    }

    func describeEntry(entry: Int64) async -> Entities.EntryDetail? {
        if let cachedDetail = inspectedDetails[entry]{
            return cachedDetail
        }
        do {
            let detail = try await entryUsecase.getEntryDetails(entry: entry)
            inspectedDetails[entry] = detail
            return detail
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            store.alert.display(msg: "describe entry failed: \(error)")
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
            
            if let grp = group {
                let _ = await openGroup(groupID: grp.id)
            }
            return true
        } catch {
            store.alert.display(msg: "move entry failed \(error)")
            return false
        }
    }
    
    func replicateEntryToGroup(entries: [Int64], newParent: Int64) async {
        store.dispatch(.alert(msg: "not support"))
    }
}
