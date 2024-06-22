//
//  MainView.swift
//  basenana
//
//  Created by Hypo on 2024/3/24.
//

import SwiftUI

@MainActor
struct ContentView: View{
    @State private var store = Store()
    @State private var appConfiguration = AppConfiguration.share
    
    init(){
        setupLogging()
    }
    
    var body: some View {
        if !store.state.fsInfo.fsApiReady {
            LoginView()
                .environment(store)
        }else {
            VStack {
                StackContentView()
                    .frame(minWidth: 1200, minHeight: 800)
            }
            .environment(store)
            .environment(\.goReadDocumentView, {
                store.dispatch(.setDestination(to: [$0.destination]))
            })
            .environment(\.goGroupListView, {
                store.dispatch(.gotoDestination($0.destination))
            })
            .environment(\.getClientSet, {
                return try ClientFactory.share.makeClient()
            })
            .environment(\.sendAlert, {
                store.dispatch(.alert(msg: $0))
            })
        }
    }
}
