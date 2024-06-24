//
//  GroupMenuView.swift
//  basenana
//
//  Created by Hypo on 2024/6/23.
//

import SwiftUI
import Foundation


struct GroupMenuView: View {
    var entry: EntryInfoModel?
    var group: GroupModel?
    
    @Environment(Store.self) private var store: Store
    
    var body: some View {
        if entry != nil {
            Section{
                Button("Open", action: {
                    if entry!.isGroup {
                        store.dispatch(.gotoDestination(.groupList(group: GroupModel(parentID: entry!.parentID, groupID: entry!.id, groupName: entry!.name))))
                    }else {
                        store.dispatch(.alert(msg: "not support open \(entry!.kind) file"))
                    }
                })
            }
        }
        
        Section{
            Menu("New") {
                Button("Group", action: {})
                Button("RSS Feed", action: {})
                Button("Dynamic Group", action: {})
            }
        }
        
        // web page
        Section{
            Button("Launch URL", action: {})
            Button("Copy URL", action: {})
        }
        
        Section{
            Button("Rename", action: {})
            Button("Delete", action: {})
        }
        
        Section{
            Menu("Move To") {
                ForEach(store.state.groupTree.children ?? []){ childGroup in
                    GroupDestinationView(
                        group: childGroup,
                        childKeyPath: \.children,
                        action: { store.dispatch(.alert(msg: "test move to \($0.groupName) ")) }
                    )
                }
            }
            Menu("Replicate To") {
                ForEach(store.state.groupTree.children ?? []){ childGroup in
                    GroupDestinationView(
                        group: childGroup,
                        childKeyPath: \.children,
                        action: { store.dispatch(.alert(msg: "test dup to \($0.groupName) ")) }
                    )
                }
            }
        }
        
        Section{
            Menu("Mark") {
                Button("As Marked", action: { print("Option 1 selected") })
                Button("As Unread", action: { print("Option 2 selected") })
            }
        }
    }
}


struct GroupDestinationView: View {
    let group: GroupModel
    let childKeyPath: KeyPath<GroupModel, [GroupModel]?>
    let action: (_: GroupModel) ->Void
    
    @Environment(Store.self) private var store: Store
    
    var body: some View {
        if group[keyPath: childKeyPath] != nil {
            DisclosureGroup(
                isExpanded: /*@START_MENU_TOKEN@*/.constant(true)/*@END_MENU_TOKEN@*/,
                content: {
                    Menu(group.groupName) {
                        Button(group.groupName, action: { action(group) })
                        Divider()
                        ForEach(group[keyPath: childKeyPath] ?? []) { childGroup in
                            GroupDestinationView(group: childGroup, childKeyPath: childKeyPath, action: action)
                        }
                    }
                },
                label: {}
            ).disclosureGroupStyle(GroupDestDisclosureStyle())
        } else {
            Button(group.groupName, action: { action(group) })
        }
    }
}


#Preview {
    GroupMenuView(entry: nil, group: nil)
}
