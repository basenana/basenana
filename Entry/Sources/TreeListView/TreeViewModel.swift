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
class TreeViewModel {
    
    var selectedGroup: Entities.Group? = nil
    var store: StateStore

    var entryTreeUserCase: EntryTreeUseCaseProtocol
    
    init(store: StateStore, entryTreeUserCase: EntryTreeUseCaseProtocol) {
        self.store = store
        self.entryTreeUserCase = entryTreeUserCase
    }
    
    func resetGroupTree() {
        print("[resetGroupTree] load and reset group root")
        do {
            let root = try entryTreeUserCase.getTreeRoot()
            guard let fc = root.children else {
                return
            }
            
            self.store.groupTree.reset(groups: fc)
        } catch {
            print("[resetGroupTree] load group root failed \(error)")
            return
        }
    }
    
    func moveEntriesToGroup(entries: [Int64], newParent: Int64) {
        
    }
}
