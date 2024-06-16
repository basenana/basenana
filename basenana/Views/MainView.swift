//
//  MainView.swift
//  basenana
//
//  Created by Hypo on 2024/3/24.
//

import SwiftUI

struct MainView: View{
    @State private var needLogin: Bool
    @State private var alertState = AlertStore()

    init(){
        setupLogging()
        do {
            let _ = try clientFactory.makeClient()
            needLogin = false
        } catch {
            log.error("make client failed: \(error), need login")
            needLogin = true
        }
    }
    
    var body: some View {
        if needLogin {
            SettingsView()
        }else {
            NavigationSplitView {
                SidebarView()
                    .frame(minWidth: 180,idealWidth: 200)
            }detail: {
            }
            .alert(alertState.alertMessage, isPresented: $alertState.needAlert){
                Button("OK", role: .cancel) {
                    alertState.reset()
                }
            }
            .environment(alertState)
        }
    }
}
