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
    @State private var refreshToggle = false
    @State private var deleteProgress = 0.0
    @State private var showProgressSheet = false
    
    var body: some View {
        OutlineGroup(GroupRoot.children ?? [], children: \.children){ child in
            NavigationLink {
                GroupView(groupID: child.groupID, refreshToggle: $refreshToggle, searchEntry: $searchEntry)
                    .id(child.groupID)
                    .navigationTitle(child.groupName)
                    .sheet(isPresented: $showProgressSheet) {
                        VStack {
                            Text("Deleting...")
                            ProgressView(value: deleteProgress)
                        }
                        .padding()
                    }            
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Confirm Delete"),
                            message: Text("Are you sure delete \"\(entryToDelete?.groupName ?? "")\" ?"),
                            primaryButton: .destructive(Text("Delete")) {
                                Task.detached {
                                    if let entryId = entryToDelete?.groupID {
                                        let children = entryService.listChildLeafs(parentID: entryId)
                                        let all = children.count
                                        showProgressSheet = true
                                        Task {
                                            defer { GroupRoot.updateAt = Date() }
                                            for child in children {
                                                await entryService.deleteEntry(entryId: child)
                                                deleteProgress += 1.0/Double(all)
                                            }
                                            try await Task.sleep(nanoseconds: 500_000_000)
                                            showProgressSheet = false
                                        }
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
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
                refreshToggle.toggle()
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
    }
    
}

