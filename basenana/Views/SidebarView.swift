//
//  SidebarView.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation
import SwiftUI
import SwiftData

struct SidebarView: View {
    @EnvironmentObject private var groupService: GroupService
    @EnvironmentObject private var docService: DocumentService
    @EnvironmentObject private var dialogueService: DialogueService

    var body: some View {
        List{
            NavigationLink {
                GroupView(groupID: inboxEntryID).id(inboxEntryID)
                    .navigationTitle("Inbox")
            } label: {
                HStack{
                    Image(systemName: "tray.fill").foregroundColor(.blue)
                    Text("Inbox")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            
            NavigationLink {
                DocumentView()
                    .navigationTitle("Unread")
            } label: {
                HStack{
                    Image(systemName: "circle.fill").foregroundColor(.brown)
                    Text("Unread")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            
            NavigationLink {
                NavigationView {
                    List {
                        NavigationLink {
                            Text("Marked")
                        } label: {
                            HStack{
                                Image(systemName: "bookmark.fill").foregroundColor(.yellow)
                                Text("Marked")
                            }.frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                        }.tag("m1")
                        NavigationLink {
                            Text("Marked2")
                        } label: {
                            HStack{
                                Image(systemName: "bookmark.fill").foregroundColor(.yellow)
                                Text("Marked")
                            }.frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                        }.tag("m2")
                    }.listStyle(.sidebar)
                }
            } label: {
                HStack{
                    Image(systemName: "bookmark.fill").foregroundColor(.yellow)
                    Text("Marked")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            Section("GROUPS"){
                SidebarGroupsView()
            }
            .onAppear{
                groupService.initGroupTree()
            }
        }
        .listStyle(.sidebar)
    }
}

struct SidebarGroupsView: View {
    private var rootGroups = GroupRoot.children ?? []
    
    var body: some View {
        OutlineGroup(rootGroups, children: \.children){ child in
            NavigationLink {
                GroupView(groupID: child.groupID).id(child.groupID)
                    .navigationTitle(child.groupName)
            } label: {
                HStack{
                    Image(systemName: "folder")
                    Text("\(child.groupName)")
                        .multilineTextAlignment(.leading)
                }.padding(.vertical, 4)
            }
        }
        .contextMenu {
            Button(action: {
                // perform some action
                print("Button 1 clicked")
            }) {
                Text("Button 1")
                Image(systemName: "1.circle")
            }
            
            Button(action: {
                // perform some action
                print("Button 2 clicked")
            }) {
                Text("Button 2")
                Image(systemName: "2.circle")
            }
        }
    }
    
}
