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
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var entryService: EntryService
    @EnvironmentObject private var groupService: GroupService
    
    private var inboxEntry: EntryModel {
        var iEntry: EntryModel = initInboxEntry()
        do {
            let data = try context.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.id == inboxEntryID}))
            
            if data.first == nil{
                iEntry = initInboxEntry()
                context.insert(iEntry)
                try context.save()
            }else{
                iEntry = data.first!
            }
            return iEntry
        }catch{
            debugPrint("fetch inbox entry failed")
        }
        return iEntry
    }
    var body: some View {
        ZStack{
            List{
                NavigationLink {
                    GroupView(groupChileren: entryService.listChildren(parentEntryID: inboxEntryID))
                } label: {
                    HStack{
                        Image(systemName: "tray.fill").foregroundColor(.blue)
                        Text("Inbox")
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                }
                
                NavigationLink {
                    DocumentView(docs: buildDocs())
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
                    //                Text("Marked")
                } label: {
                    HStack{
                        Image(systemName: "bookmark.fill").foregroundColor(.yellow)
                        Text("Marked")
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                }
                Section("GROUPS"){
                    SidebarGroupsView(rootGroup: groupService.rootGroup())
                }
            }
            .listStyle(.sidebar)
            
            VStack {
                Spacer(minLength: 10)
                HStack(alignment: .firstTextBaseline){
                    Button(action: {
                        // Handle your button action here
                    }) {
                        Image(systemName: "plus")
                    }
                    Button(action: {
                        // Handle your button action here
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 10)
                .padding()
                .buttonStyle(PlainButtonStyle())
                .background(.clear)
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

struct SidebarGroupsView: View {
    @EnvironmentObject private var entryService: EntryService
    @ObservedObject var rootGroup: GroupTreeRootViewModel
    
    var body: some View {
        OutlineGroup(rootGroup.subGroups, children: \.subGroups){ subGroup in
            NavigationLink {
                GroupView(groupChileren: entryService.listChildren(parentEntryID: subGroup.entry.id))
                    .id(subGroup.entry.id)
            } label: {
                HStack{
                    Image(systemName: "folder")
                    Text("\(subGroup.entry.name)")
                        .multilineTextAlignment(.leading)
                }.padding(.vertical, 4)
            }
        }
    }
}
