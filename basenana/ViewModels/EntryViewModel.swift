//
//  EntryViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation


class EntryViewModel: ObservableObject, Identifiable {
    @Published var id: Int64
    @Published var name: String
    @Published var kind: String
    @Published var size: Int64
    @Published var createdAt: Date
    @Published var changedAt: Date
    @Published var modifiedAt: Date
    @Published var accessAt: Date
    
    init(entryInfo: EntryInfo) {
        self.id = entryInfo.id
        self.name = entryInfo.name
        self.kind = entryInfo.kind
        self.size = 0
        self.createdAt = entryInfo.createdAt
        self.changedAt = entryInfo.changedAt
        self.modifiedAt = entryInfo.modifiedAt
        self.accessAt = entryInfo.accessAt
    }
}
