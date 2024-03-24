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
    
    func initGroupTree() {
        var needInitGroups = [GroupRoot]
        
        while !needInitGroups.isEmpty{
            let nextGroup = needInitGroups[0]
            needInitGroups.remove(at: 0)
            let gid = nextGroup.groupID
            do{
                nextGroup.children = try modelContext.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{ en in
                    en.parent == gid && en.kind == "group" && !en.name.starts(with: ".")
                })).map({
                    GroupModel(groupID: $0.id, groupName: $0.name)
                })
            }catch{
                print("query group \(nextGroup.groupID) children failed")
            }
            
            if nextGroup.children == nil || nextGroup.children!.isEmpty{
                nextGroup.children = nil
                continue
            }
            
            for subGroup in nextGroup.children!{
                needInitGroups.append(subGroup)
            }
        }
    }
    
    func reflush() {
        self.objectWillChange.send()
    }
}
