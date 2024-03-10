//
//  EntryService.swift
//  basenana
//
//  Created by Hypo on 2024/3/7.
//

import Foundation
import SwiftData
import SwiftUI


class EntryService: ObservableObject {
    
    @Environment(\.modelContext) private var context

    func rootEntry() -> EntryViewModel {
        return EntryViewModel()
    }
    
    func inboxEntry() -> EntryViewModel {
        return EntryViewModel()
    }
    
    func quickInbox(urlStr: String, fileType: String, isClusterFree:Bool) {
        return
    }

    func getEntry(entryID: Int64) -> EntryViewModel {
        return EntryViewModel()
    }
    
    func listChildren(parentEntryID: Int64) -> [EntryViewModel] {
        return []
    }

    func listRootGroupTree() -> [GroupTreeViewModel]{
        return []
    }

}
