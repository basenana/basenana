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
        AuthClient().reflushToken()
    }
    
    var body: some View {
        if clientSet == nil{
            SettingsView()
        }else {
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
}
