//
//  MainView.swift
//  basenana
//
//  Created by Hypo on 2024/3/24.
//

import SwiftUI


struct MainView: View{
    
    @State private var search: String = ""
    
    init(){
        setupLogging()
        AuthClient().reflushToken()
    }
    
    var body: some View {
        // fixme
        if !authStatus.hasAccessToken {
            SettingsView()
        }else {
            NavigationSplitView {
                SidebarView()
                    .frame(minWidth: 180,idealWidth: 180)
            }detail: {
            }
            .searchable(text: $search) {}
        }
    }
}
