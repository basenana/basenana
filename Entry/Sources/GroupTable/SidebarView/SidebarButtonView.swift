//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI
import Styleguide

@available(macOS 14.0, *)
struct SidebarButtonView: View {
    var body: some View {
        HStack(content: {
            Button(action: {
//                store.dispatch(.showSheet(sheetKind: .quickInbox))
            }, label: {
                Image(systemName: "tray.and.arrow.down")
            })
            .buttonStyle(.accessoryBar)
            
            Button(action: {
//                store.dispatch(.showSheet(sheetKind: .createGroup(parent: store.getSelectedGroup(), grpType: .standard)))
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)
            
            Spacer()
            
            Button(action: {
//                store.dispatch(.setDestination(to: [.workflowDashboard]))
            }, label: {
                Image(systemName: "ellipsis.curlybraces")
            })
            .buttonStyle(.accessoryBar)
        })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
        .padding(5)
    }
}

