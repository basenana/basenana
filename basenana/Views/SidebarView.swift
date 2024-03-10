//
//  SidebarView.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation
import SwiftUI

struct SidebarView: View {
    var groups: [GroupViewModel] = []
    
    var body: some View {
        List{
            NavigationLink {
                Text("Inbox")
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
            
            Text("GROUPS")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
                .padding(.leading, -8)
            ForEach(groups) { grp in
                OutlineGroup(grp, children: \.subGroups){ subGroup in
                    NavigationLink {
                        GroupView(group: subGroup)
                    } label: {
                        HStack{
                            Image(systemName: "folder")
                            Text("\(subGroup.name)")
                                .multilineTextAlignment(.leading)
                        }.padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

func buildGroup(id: Int64) -> GroupNode {
    let en = EntryInfo(
        id: id, name: "group \(id)", kind: "raw", createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date())
    
    let sub1 = EntryInfo(
        id: id*10 + 1, name: "group \(id).1", kind: "raw", createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date())
    
    let sub2 = EntryInfo(
        id: id*10 + 2, name: "group \(id).2", kind: "raw", createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date())
    
    let sub3 = EntryInfo(
        id: id*100 + 1, name: "group \(id).2.1", kind: "raw", createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date())
    
    return GroupNode(entry: en, subGroups: [
            GroupNode(entry: sub1, subGroups: []),
            GroupNode(entry: sub2, subGroups: [
                GroupNode(entry: sub3, subGroups: []),
            ]),
        ])
}

func buildGroups() -> [GroupViewModel] {
    var result: [GroupViewModel] = []
    for i in 1...10 {
        result.append(GroupViewModel(group: buildGroup(id: Int64(i))))
    }
    return result
}


#Preview {
    SidebarView(groups: buildGroups())
}
