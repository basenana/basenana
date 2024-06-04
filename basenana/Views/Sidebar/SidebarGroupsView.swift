//
//  SidebarGroupsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI

struct SidebarGroupsView: View {
    @Binding var searchEntry: Int64?
    
    var body: some View {
        OutlineGroup(GroupRoot.children ?? [], children: \.children){ child in
            NavigationLink {
                GroupView(groupID: child.groupID, searchEntry: $searchEntry)
                    .id(child.groupID)
                    .navigationTitle(child.groupName)
            } label: {
                HStack{
                    Image(systemName: "folder")
                    Text("\(child.groupName)")
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 4)
            }
            .id(child.groupID)
            .dropDestination(for: String.self){ entryIDInfos, localtion in
                groupService.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryIDInfos), groupID: child.groupID)
                return false
            }
            .draggable(IDHelper(kind: "group", id: child.groupID).Encode())
        }
        .contextMenu {
            Button(action: {
                // perform some action
            }) {
                Text("Button 1")
                Image(systemName: "1.circle")
            }
            
            Button(action: {
                // perform some action
            }) {
                Text("Button 2")
                Image(systemName: "2.circle")
            }
        }
    }
    
}

