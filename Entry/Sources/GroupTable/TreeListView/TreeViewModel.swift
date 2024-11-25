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
    var groupTree: GroupTree = GroupTree()
    
    var root: Entities.Group = UnknownGroup.shared
    var inbox: Entities.Group = UnknownGroup.shared

    // current opened group
    var opendGroup: EntryDetail? = nil
    var opendGroupChildren: [EntryRow] = []
    
    var showCreateGroup: Bool = false
    var createGroupInParent: Int64 = 0
    var createGroupType: GroupType = .standard
    var showQuickInbox: Bool = false
    

    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol

    public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }
    
    // current parent
    func findCurrentParent() async -> Entities.Group {
        // current opened group's parent
        if let og = opendGroup {
            print("findCurrentParent: opened group \(og.name)")
            if let p = await getGroup(groupID: og.id) {
                return p
            }
        }
        // root group
        print("findCurrentParent: root \(store.fsInfo.rootID)")
        if let r = await getGroup(groupID: store.fsInfo.rootID){
            return r
        }
        print("findCurrentParent: not found")
        return UnknownGroup.shared
    }
    
    func resetGroupTree() async {
        print("[resetGroupTree] load and reset group root")
        do {
            root = try await entryUsecase.getTreeRoot()
            guard let fc = root.children else {
                return
            }
            inbox = await getGroup(groupID: store.fsInfo.inboxID) ?? UnknownGroup.shared
            
            self.groupTree.reset(groups: fc)
        } catch {
            store.alert.display(msg: "load group tree failed: \(error)")
        }
    }
    
    func openGroup(groupID: Int64) async {
        do {
            opendGroup = try await entryUsecase.getEntryDetails(entry: groupID)
            if opendGroup == nil || !opendGroup!.isGroup {
                throw BizError.notGroup
            }
            
            self.opendGroupChildren = []
            let newChildren = try await entryUsecase.listChildren(entry: groupID)
            for child in newChildren {
                self.opendGroupChildren.append(EntryRow(info: child))
            }
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            store.alert.display(msg: "open group failed: \(error)")
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
        
        if let og = opendGroup {
            if og.id == store.fsInfo.inboxID {
                // reopen inbox
                let _ = await openGroup(groupID: og.id)
            }
        }
        return true
    }
    
    func createGroup(parentID: Int64, option: EntryCreate) async {
        guard groupTree.getGroup(groupID: parentID) != nil else {
            store.alert.display(msg: "creatr group failed: parent \(parentID) not exist")
            return
        }
        
        do {
            let newGroup = try await entryUsecase.createGroups(parent: parentID, option: option)
            
            // insert to the tree
            groupTree.addChildGroup(parentID: parentID, child: newGroup.toGroup()!, grandChildren: [])
            
            // insert to the window
            if let openedGroup = opendGroup {
                if openedGroup.id == parentID {
                    opendGroupChildren.append(EntryRow(info: newGroup))
                }
            }
        } catch {
            store.alert.display(msg: "creatr group failed: \(error)")
            return
        }
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
        
        let parent = await describeEntry(entry: newParent)
        guard parent != nil else {
            return false
        }
        
        if !parent!.isGroup {
            store.alert.display(msg: "\(parent!.name) not a group")
            return false
        }
        
        for url in entryURLs {
            print("[moveEntriesToGroup] move \(url) to \(parent!.id)")
            switch url.scheme {
            case "basenana":
                print("[moveEntriesToGroup] move internal object")
                
                let targetID = parseEntryIDFromURL(url: url)
                guard targetID != nil && targetID! > 0 else {
                    store.alert.display(msg: "\(url) not a valid entry")
                    return false
                }
                
                let target = await describeEntry(entry: targetID!)
                guard target != nil else {
                    store.alert.display(msg: "\(targetID!) not a valid entry")
                    return false
                }
                
                do {
                    try await entryUsecase.changeParent(entry: target!.id, newParent: parent!.id)
                    
                    // update views
                    if target!.isGroup {
                        if let grp = groupTree.getGroup(groupID: target!.id) {
                            groupTree.removeChildGroup(parentID: target!.parent, childID: target!.id)
                            groupTree.addChildGroup(parentID: parent!.id, child: grp.group, grandChildren: grp.children)
                        }
                    }
                    
                    if let og = opendGroup {
                        if og.id == target!.parent { // remove from old view
                            opendGroupChildren.removeAll { $0.id == target?.id }
                        }
                        if og.id == newParent { // insert to new view
                            opendGroupChildren.append(EntryRow(info: target!.toInfo()!))
                        }
                    }
                    
                    return true
                } catch {
                    store.alert.display(msg: "move entry failed \(error)")
                    return false
                }
                
            case "file":
                print("[moveEntriesToGroup] upload file")
                store.alert.display(msg: "not support upload a file")
            default:
                print("[moveEntriesToGroup] unknown url schema \(url)")
                return false
            }
        }
        return false
    }
    
    func replicateEntryToGroup(entry: Int64, newParent: Int64) {
        store.dispatch(.alert(msg: "not support"))
    }
}
