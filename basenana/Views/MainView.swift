//
//  MainView.swift
//  basenana
//
//  Created by Hypo on 2024/3/24.
//

import SwiftUI


struct MainView: View{
    
    init(){
        setupLogging()
        let authClient = AuthClient(host: "127.0.0.1", port: 7081)
        do {
            try authClient.reflushToken(accessTokenKey: "ak-test-1", secretToken: "sk-test-1")
        } catch {
            log.error("reflush token error \(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            SidebarView()
                .frame(minWidth: 180,idealWidth: 180)
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
        }
    }
}
