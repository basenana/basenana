//
//  Container+Injection.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import SwiftUI
import Swinject
import Domain
import Feature


@MainActor
public struct ContentView: View {
    @State private var state = StateStore.shared

    public init() {}

    public var body: some View {
        VStack{
            if !state.fsInfo.fsApiReady {
                LoginView()
                    .frame(minWidth: 400, maxWidth: 400, minHeight: 500, maxHeight: 500)
            } else {
                StackContentView()
            }
        }
        .preferredColorScheme(state.setting.appearance.overColorScheme)
        .environment(\.stateStore, state)
    }
}

struct DocumentWindowView: View {
    let uri: String

    @State private var container = DIContainer(state: .shared)

    var body: some View {
        DocumentReadView(viewModel: container.c.resolve(DocumentReadViewModel.self, argument: uri)!)
            .id(uri)
    }
}


