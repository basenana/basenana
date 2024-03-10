//
//  GroupTreeViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/3/7.
//

import Foundation


class GroupTreeViewModel: ObservableObject, Identifiable {
    @Published var id: Int64 = 1
    @Published var entry: EntryViewModel
    
    var subGroups: [GroupTreeViewModel]? {
        get {
            let children = entry.children
            if children.isEmpty{
                return nil
            }
            
            var result: [GroupTreeViewModel] = []
            for en in children{
                result.append(GroupTreeViewModel(entry: en))
            }
            return result
        }
    }

    init(entry: EntryViewModel) {
        self.id = entry.id
        self.entry = entry
    }
}


