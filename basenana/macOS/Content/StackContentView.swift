//
//  StackContentView.swift
//  basenana
//
//  Created by Hypo on 2024/6/20.
//

import SwiftUI
import Foundation
import Domain
import Feature
import Factory


struct StackContentView: View {

    @State private var container: DIContainer
    @State private var destinations: [Destination]
    @State private var alertMessage: String = ""
    @State private var hasAlert: Bool = false
    @State private var searchContent: String = ""
    @State private var isSearchActive: Bool = false

    init() {
        self.container = DIContainer(state: .shared)
        self._destinations = State(initialValue: StateStore.shared.destinations)
    }

    public var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: container.c.resolve(TreeViewModel.self)!)
                .frame(minWidth: 180, idealWidth: 200)
        } detail: {
            NavigationStack(path: $destinations) {
                StackBannerView()
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .groupList(groupUri: let groupUri):
                            GroupTableView(groupUri: groupUri, viewModel: container.c.resolve(GroupTableViewModel.self)!)
                                .id(groupUri)

                        case .listDocuments(prespective: let prespective):
                            DocumentListView(viewModel: container.c.resolve(DocumentListViewModel.self, name: prespective.Title)!).id(prespective).navigationTitle(prespective.Title)
                        case .readDocument(uri: let uri):
                            DocumentReadView(viewModel: container.c.resolve(DocumentReadViewModel.self, argument: uri)!).id(uri)

                        case .workflowDashboard:
                            WorkflowListView(viewModel: container.c.resolve(WorkflowListViewModel.self)!)
                        case .workflowDetail(workflow: let workflow):
                            WorkflowDetailView(viewModel: container.c.resolve(WorkflowDetailViewModel.self, argument: workflow)!).id(workflow)
                        case .workflowCreate:
                            WorkflowCreateView(viewModel: container.c.resolve(WorkflowCreateViewModel.self)!)
                        case .searchDocuments:
                            SearchView(search: searchContent, viewModel: container.c.resolve(SearchViewModel.self)!)
                        default:
                            Text("unknown destination")
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .setDestination)) { notification in
            if let ds = notification.object as? [Destination] {
                destinations = ds
                StateStore.shared.destinations = ds
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gotoDestination)) { notification in
            if let dest = notification.object as? Destination {
                destinations.append(dest)
                StateStore.shared.destinations = destinations
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("alert"))) { [self] notification in
            if let msg = notification.object as? String {
                alertMessage = msg
                hasAlert = true
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .status) {
                BackgroundJobView(state: .shared)
                NotificationView(state: .shared)
            }
        }
        .searchable(text: $searchContent)
        .onSubmit(of: .search) {
            isSearchActive = true
            StateStore.shared.destinations.append(.searchDocuments)
        }
        .alert(alertMessage, isPresented: $hasAlert) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: StateStore.shared.destinations) { _, newValue in
            destinations = newValue
        }
    }
}

struct StackBannerView: View {
    @StateObject private var chatViewModel: FridayChatViewModel

    init() {
        let container = DIContainer(state: .shared)
        let useCase = container.c.resolve(FridayUseCaseProtocol.self)!
        self._chatViewModel = StateObject(wrappedValue: FridayChatViewModel(fridayUseCase: useCase))
    }

    public var body: some View {
        FridayChatView(viewModel: chatViewModel)
    }
}

struct FridayPromptLabelView: View {
    let onTap: () -> Void

    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                Text("Ask Friday anything...")
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .font(.callout)
            .foregroundStyle(.blue)
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
