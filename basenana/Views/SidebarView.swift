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
    @Query(filter: #Predicate<EntryModel>{$0.parent == rootEntryID}, sort: \EntryModel.name) private var rootChileren: [EntryModel]

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
    
    @State private var rootGroups: [GroupTreeViewModel] = []
    
    var body: some View {
        List{
            NavigationLink {
                GroupView(groupEntry: inboxEntry)
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
                Text("Marked")
            } label: {
                HStack{
                    Image(systemName: "bookmark.fill").foregroundColor(.yellow)
                    Text("Marked")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            
            Section("GROUPS"){
                OutlineGroup(rootGroups, children: \.subGroups){ subGroup in
                    NavigationLink {
                        GroupView(groupEntry: subGroup.entry)
                    } label: {
                        HStack{
                            Image(systemName: "folder")
                            Text("\(subGroup.entry.name)")
                                .multilineTextAlignment(.leading)
                        }.padding(.vertical, 4)
                    }
                }
            }.onAppear{
                rootGroups = GroupTreeViewModel(entry: initRootEntry(), modelContext: context).subGroups ?? []
            }
        }
    }
}
