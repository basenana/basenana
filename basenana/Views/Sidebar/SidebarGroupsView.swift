//
//  SidebarGroupsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI

struct SidebarGroupsView: View {
    @State private var showAlert = false
    @State private var refreshToggle = false
    @State private var deleteProgress = 0.0
    @State private var showProgressSheet = false
    
    @Environment(Store.self) private var store: Store
    
    var body: some View {
        OutlineGroup(store.state.groupTree.children ?? [], children: \.children){ child in
            NavigationLink(value: Destination.groupList(group: child), label: {
                HStack{
                    Image(systemName: "folder")
                    Text("\(child.groupName)")
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 4)
            })
            .dropDestination(for: String.self){ entryIDInfos, localtion in
                do {
                    try service.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryIDInfos), groupID: child.groupID)
                    refreshToggle.toggle()
                } catch {
                }
                return false
            }
            .draggable(IDHelper(kind: "group", id: child.groupID).Encode())
        }
    }
}

