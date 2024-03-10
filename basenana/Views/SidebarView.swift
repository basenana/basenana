//
//  SidebarView.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation
import SwiftUI

struct SidebarView: View {
    @Binding var groups: [GroupTreeViewModel]
    
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
            
            Section("GROUPS"){
                OutlineGroup(groups, children: \.subGroups){ subGroup in
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
            }
        }
    }
}
