//
//  GroupService.swift
//  basenana
//
//  Created by Hypo on 2024/3/15.
//

import Foundation
import SwiftData


class GroupService: ObservableObject {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func rootGroup() -> GroupTreeRootViewModel{
        return GroupTreeRootViewModel(modelContext:modelContext)
    }
    
    func reflush() {
        self.objectWillChange.send()
    }
}
