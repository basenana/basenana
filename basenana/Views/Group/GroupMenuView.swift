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
    
    @State var property = PropertyViewModel()
    @Environment(Store.self) private var store: Store
    @Environment(\.sendAlert) var sendAlert
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
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
                    Button("Group", action: {
                        store.dispatch(.showSheet(sheetKind: .createGroup(parent: store.getSelectedGroup(), grpType: .standard)))
                    })
                    Button("RSS Feed", action: {
                        store.dispatch(.showSheet(sheetKind: .createGroup(parent: store.getSelectedGroup(), grpType: .feed)))
                    })
                    Button("Dynamic Group", action: {})
                }
            }
            
            // web page
            Section{
                Button("Launch URL", action: {
                    for pk in [PropertyWebPageURL, PropertyWebSiteURL]{
                        if let pro = property.getProperty(k: pk){
                            if let pageUrl = URL(string: pro.value){
                                openURL.callAsFunction(pageUrl){ result in
                                    log.info("open docuemnt url \(pro.value), resule: \(result)")
                                }
                                break
                            }
                        }
                    }
                })
                Button("Copy URL", action: {
                    for pk in [PropertyWebPageURL, PropertyWebSiteURL]{
                        if let pro = property.getProperty(k: pk){
                            copyToClipBoard(textToCopy: pro.value)
                            break
                        }
                    }
                })
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
            
            if entry != nil {
                Section{
                    Menu("Mark") {
                        Button("As Marked", action: { print("Option 1 selected") })
                        Button("As Unread", action: { print("Option 2 selected") })
                    }
                }
            }
        }
        .task {
            if entry != nil || group != nil {
                do {
                    try await property.initEntry(entryID: entry?.id ?? group?.groupID ?? -1)
                } catch {
                    log.warning("fetch entry property failed \(error)")
                }
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
