//
//  EntryViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation
import SwiftUI


class EntryViewModel: ObservableObject, Identifiable {
    @EnvironmentObject var entryService: EntryService
    
    @Published var id: Int64 = -1
    @Published var name: String = "unknown"
    @Published var kind: String = "group"
    @Published var size: Int64 = 0
    
    @Published var createdAt: Date
    @Published var changedAt: Date
    @Published var modifiedAt: Date
    @Published var accessAt: Date
    

    var children: [EntryViewModel] {
        get {
            if !isGroup(){
                return []
            }
            return entryService.listChildren(parentEntryID: id)
        }
    }
    
    init(model : EntryModel) {
        self.id = model.id
        self.name = model.name
        self.kind = model.kind
        self.size = model.size
        self.createdAt = model.createdAt
        self.changedAt = model.changedAt
        self.modifiedAt = model.modifiedAt
        self.accessAt = model.accessAt
    }
    
    func createChildren(){
    }
    
    func removeChildren(){
    }
    
    func isGroup() -> Bool {
        return kind == "group"
    }
}

