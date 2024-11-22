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


@available(macOS 14.0, *)
@Observable
@MainActor
public class TreeViewModel {
    
    // tree store
    var groupTree: GroupTree = GroupTree()
    
    var root: Entities.Group = UnknownGroup.shared
    var inbox: Entities.Group = UnknownGroup.shared

    // current opened group
    var opendGroup: Entities.Group? = nil
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
    func findCurrentParent() -> Entities.Group {
        // current opened group's parent
        if let og = opendGroup {
            print("findCurrentParent: opened group \(og.groupName)")
            if let p = getGroup(groupID: og.id) {
                return p
            }
        }
        // root group
        print("findCurrentParent: root \(store.fsInfo.rootID)")
        if let r = getGroup(groupID: store.fsInfo.rootID){
            return r
        }
        print("findCurrentParent: not found")
        return UnknownGroup.shared
    }
    
    func resetGroupTree() {
        print("[resetGroupTree] load and reset group root")
        do {
            root = try entryUsecase.getTreeRoot()
            guard let fc = root.children else {
                return
            }
            inbox = getGroup(groupID: store.fsInfo.inboxID) ?? UnknownGroup.shared
            
            self.groupTree.reset(groups: fc)
        } catch {
            store.alert.display(msg: "load group tree failed: \(error)")
        }
    }
    
    func openGroup(groupID: Int64) {
        do {
            let groupEntry = try entryUsecase.getEntryDetails(entry: groupID)
            if !groupEntry.isGroup {
                throw BizError.notGroup
            }
            self.opendGroup = groupEntry.toGroup()
            self.opendGroupChildren = []
            
            let newChildren = try entryUsecase.listChildren(entry: groupID)
            for child in newChildren {
                self.opendGroupChildren.append(EntryRow(info: child))
            }
        } catch {
            store.alert.display(msg: "open group failed: \(error)")
        }
    }
    
    // quick inbox
    func quickInbox(url: String, title: String, fileType: String, errorMsg: Binding<String>) {
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
            try entryUsecase.quickInbox(url: url, fileName: title, fileType: safeFileType)
        } catch {
            errorMsg.wrappedValue = "inbox failed: \(error)"
            return
        }
        
        if let og = opendGroup {
            if og.id == store.fsInfo.inboxID {
                // reopen inbox
                openGroup(groupID: og.id)
            }
        }
    }
    
    func createGroup(parentID: Int64, option: EntryCreate){
        guard groupTree.getGroup(groupID: parentID) != nil else {
            store.alert.display(msg: "creatr group failed: parent \(parentID) not exist")
            return
        }
        
        do {
            let newGroup = try entryUsecase.createGroups(parent: parentID, option: option)
            
            // insert to the tree
            groupTree.addChildGroup(parentID: parentID, childID: newGroup.id, childName: newGroup.name, grandChildren: [])
            
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
    
    func describeEntry(entry: Int64) -> Entities.EntryDetail? {
        do {
            return try entryUsecase.getEntryDetails(entry: entry)
        } catch {
            store.alert.display(msg: "describe entry failed: \(error)")
        }
        return nil
    }
    
    func getGroup(groupID: Int64) -> Entities.Group? {
        do {
            let groupEntry = try entryUsecase.getEntryDetails(entry: groupID)
            return groupEntry.toGroup()
        } catch {
            store.alert.display(msg: "get group failed: \(error)")
        }
        return nil
    }
    
    func moveEntriesToGroup(entries: [Int64], newParent: Int64) {
        
    }
}
