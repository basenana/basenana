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
    
    init() {
        let nowAt = Date()
        self.createdAt = nowAt
        self.changedAt = nowAt
        self.modifiedAt = nowAt
        self.accessAt = nowAt
    }
    
    func createChildren(){
    }
    
    func removeChildren(){
    }
    
    func isGroup() -> Bool {
        return kind == "group"
    }
}

