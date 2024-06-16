//
//  SidebarGroupsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI

struct SidebarGroupsView: View {
    @State private var showAlert = false
    @State private var entryToDelete: GroupViewModel? = nil
    @State private var refreshToggle = false
    @State private var deleteProgress = 0.0
    @State private var showProgressSheet = false
    @Environment(AlertStore.self) var alert
    
    var body: some View {
        OutlineGroup(GroupRoot.children ?? [], children: \.children){ child in
            NavigationLink {
                GroupView(groupID: child.groupID, refreshToggle: $refreshToggle)
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
                                        do {
                                            let children = try service.listChildLeafs(parentID: entryId)
                                            let all = children.count
                                            showProgressSheet = true
                                            defer { GroupRoot.updateAt = Date() }
                                            for child in children {
                                                try await service.deleteEntry(entryId: child)
                                                deleteProgress += 1.0/Double(all)
                                            }
                                            try await Task.sleep(nanoseconds: 500_000_000)
                                            showProgressSheet = false
                                        } catch {
                                            alert.trigger(message: "\(error)")
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
                do {
                    try service.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryIDInfos), groupID: child.groupID)
                    refreshToggle.toggle()
                } catch {
                    alert.trigger(message: "\(error)")
                }
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure delete \"\(entryToDelete?.groupName ?? "")\" ?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let entryId = entryToDelete?.groupID {
                        Task.detached{
                            do {
                                try await service.deleteEntry(entryId: entryId)
                            } catch {
                                alert.trigger(title: "Delete Entry Error", message: "\(error)")
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
}

