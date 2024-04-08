//
//  MainView.swift
//  basenana
//
//  Created by Hypo on 2024/3/24.
//

import SwiftUI


struct MainView: View{
    @State private var isShowingQuickInbox = false
    @State private var isShowingCreateDoc = false

    var body: some View {
        NavigationView {
            SidebarView()
                .frame(minWidth: 180,idealWidth: 180)
        }
        .sheet(isPresented: $isShowingCreateDoc) {
            QuickDocumentView(isShowingQuickDocument: $isShowingCreateDoc)
        }
        .sheet(isPresented: $isShowingQuickInbox) {
            QuickInboxView(isShowingQuickInbox: $isShowingQuickInbox)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    NSApp.keyWindow?.initialFirstResponder?.tryToPerform(
                        #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                }, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    isShowingCreateDoc.toggle()
                }, label: {
                    Image(systemName: "doc")
                })
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    isShowingQuickInbox.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
    }
}
