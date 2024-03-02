//
//  GroupViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation

class GroupViewModel: ObservableObject, Identifiable {
    @Published var id: Int64
    @Published var name: String
    @Published var kind: String
    @Published var createdAt: Date
    @Published var changedAt: Date
    @Published var modifiedAt: Date
    @Published var accessAt: Date
    @Published var subGroups: [GroupViewModel]?
    @Published var isToggle: Bool
    
    init(group: GroupNode) {
        self.id = group.entry.id
        self.name = group.entry.name
        self.kind = group.entry.kind
        self.createdAt = group.entry.createdAt
        self.changedAt = group.entry.changedAt
        self.modifiedAt = group.entry.modifiedAt
        self.accessAt = group.entry.accessAt
        self.isToggle = false
        
        self.subGroups = []
        for subGroup in group.subGroups{
            self.subGroups!.append(GroupViewModel(group: subGroup))
        }
    }
}
