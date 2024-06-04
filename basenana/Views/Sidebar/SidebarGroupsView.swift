//
//  SidebarGroupsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI

struct SidebarGroupsView: View {
    @Binding var searchEntry: Int64?
    
    @State private var showAlert = false
    @State private var entryToDelete: GroupViewModel? = nil
    
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
            .contextMenu {
                Button(action: {
                    showAlert = true
                    entryToDelete = child
                }) {
                    Text("Delete")
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Confirm Delete \(entryToDelete?.groupName ?? "") ?", isPresented: $showAlert) {
            Button("Confirm", role: .destructive) {
                if let entryId = entryToDelete?.groupID {
                    Task.detached { entryService.deleteEntry(entryId: entryId) }
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
    
}

