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

    @State private var state = StateStore.shared
    @State private var container = DIContainer(state: .shared)
    @State private var chatViewModel: FridayChatViewModel?

    private var resolvedChatViewModel: FridayChatViewModel {
        if let vm = chatViewModel {
            return vm
        }
        let fridayUseCase = container.c.resolve(FridayUseCaseProtocol.self)!
        let entryUseCase = container.c.resolve(EntryUseCaseProtocol.self)!
        let vm = FridayChatViewModel(fridayUseCase: fridayUseCase, entryUseCase: entryUseCase)
        chatViewModel = vm
        return vm
    }

    var body: some View {
        if state.fsInfo.fsApiReady {
            DocumentReadView(viewModel: container.c.resolve(DocumentReadViewModel.self, argument: uri)!, chatViewModel: resolvedChatViewModel)
                .id(uri)
        }
    }
}


