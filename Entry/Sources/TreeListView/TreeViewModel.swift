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


@MainActor
class TreeViewModel: Observable {
    
    public var selectedGroup: Entities.Group? = nil
    public var store: StateStore
    
    private var entryTreeUserCase: EntryTreeUseCaseProtocol
    
    init(store: StateStore, entryTreeUserCase: EntryTreeUseCaseProtocol) {
        self.store = store
        self.entryTreeUserCase = entryTreeUserCase
    }
    
    func resetGroupTree() {
        
    }
    
    func moveEntriesToGroup(entries: [Int64], newParent: Int64) {
        
    }
}


