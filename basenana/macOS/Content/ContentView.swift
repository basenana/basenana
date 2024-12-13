//
//  Container+Injection.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import SwiftUI
import Swinject
import AppState


@MainActor
struct ContentView: View {
    @State private var state = StateStore.shared
    @State private var environment = Environment.shared
    
    var body: some View {
        VStack{
            if !state.fsInfo.fsApiReady || environment.clientSet == nil {
                LoginView()
                    .frame(minWidth: 400, maxWidth: 400, minHeight: 500, maxHeight: 500)
            } else {
                StackContentView(state: state)
            }
        }
        .preferredColorScheme(state.setting.appearance.overColorScheme)
    }
}


