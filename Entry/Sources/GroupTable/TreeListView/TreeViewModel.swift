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
    var selectedLeaf: Entities.Group? {
        get {
            if case .groupList(group: let groupID) = store.sidebarSelection {
                return getGroup(groupID: groupID)
            }
            return nil
        }
    }
    
    // current opened group
    var opendGroupChildren: [EntryRow] = []
    
    var store: StateStore
    var treeUsecase: EntryTreeUseCaseProtocol
    var entryUsecase: EntryUseCaseProtocol

    public init(store: StateStore, treeUsecase: EntryTreeUseCaseProtocol, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.treeUsecase = treeUsecase
        self.entryUsecase = entryUsecase
    }
    
    func resetGroupTree() {
        print("[resetGroupTree] load and reset group root")
        do {
            let root = try treeUsecase.getTreeRoot()
            guard let fc = root.children else {
                return
            }
            
            self.groupTree.reset(groups: fc)
        } catch {
            store.alert.display(msg: "load group tree failed: \(error)")
        }
    }
    
    func openGroup(groupID: Int64) {
        do {
            self.opendGroupChildren = []
            let newChildren = try treeUsecase.listChildren(entry: groupID)
            for child in newChildren {
                self.opendGroupChildren.append(EntryRow(info: child))
            }
        } catch {
            store.alert.display(msg: "open group failed: \(error)")
            return
        }
    }
    
    func getGroup(groupID: Int64) -> Entities.Group? {
        return nil
    }

    func moveEntriesToGroup(entries: [Int64], newParent: Int64) {
        
    }
}
