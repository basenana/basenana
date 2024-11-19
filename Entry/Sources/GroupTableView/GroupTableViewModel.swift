//
//  GroupTableViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/10/14.
//

import SwiftUI
import Foundation
import Entities
import AppState
import UseCase


@available(macOS 14.0, *)
@Observable
@MainActor
public class GroupTableViewModel {
    var id: Int64
    var children: [EntryRow] = []
    
    var selection: Set<EntryRow.ID> = []
    var document: DocumentDetail? = nil
    
    var store: StateStore
    var usercase: EntryTreeUseCase
    
    init(id: Int64, store: StateStore, usercase: EntryTreeUseCase) {
        self.id = id
        self.store = store
        self.usercase = usercase
    }
    
    func loadChildren() {
        let newChildren = try! usercase.listChildren(entry: id)
        for child in newChildren {
            self.children.append(EntryRow(info: child))
        }
    }
}


struct EntryRow: Hashable, Identifiable {
    var id: Int64
    var name: String
    var kind: String
    var isGroup: Bool
    var size: Int64
    var parentID: Int64
    
    var createdAt: Date
    var changedAt: Date
    var modifiedAt: Date
    var accessAt: Date
    
    var info: EntryInfo
    
    init(info: EntryInfo){
        self.id = info.id
        self.name = info.name
        self.kind = info.kind
        self.isGroup = info.isGroup
        self.size = info.size
        self.parentID = info.parentID
        self.createdAt = info.createdAt
        self.changedAt = info.changedAt
        self.modifiedAt = info.modifiedAt
        self.accessAt = info.accessAt
        self.info = info
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(info.id)
    }
    
    static func == (lhs: EntryRow, rhs: EntryRow) -> Bool {
        return lhs.info.id == rhs.info.id
    }
}
