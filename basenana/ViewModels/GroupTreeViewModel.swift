//
//  GroupTreeViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/3/7.
//

import Foundation
import SwiftData


class GroupTreeViewModel: ObservableObject, Identifiable {
    @Published var entry: EntryModel
    private var modelContext: ModelContext
    
    init(entry: EntryModel, modelContext: ModelContext) {
        self.entry = entry
        self.modelContext = modelContext
    }
    
    var subGroups: [GroupTreeViewModel]? {
        get {
            var children: [EntryModel] = []
            do {
                let entryID = entry.id
                let data = try modelContext.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{ en in
                    en.parent == entryID}))
                children = data
            }catch{
                debugPrint("fetch inbox entry failed")
            }
            
            if children.isEmpty {
                return nil
            }
            
            var result: [GroupTreeViewModel] = []
            for en in children{
                if !en.isGroup() || en.name.starts(with: "."){
                    continue
                }
                result.append(GroupTreeViewModel(entry: en, modelContext: modelContext))
            }
            return result
        }
    }
}


