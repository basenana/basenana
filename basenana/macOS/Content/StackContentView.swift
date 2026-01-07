//
//  StackContentView.swift
//  basenana
//
//  Created by Hypo on 2024/6/20.
//

import SwiftUI
import Foundation
import AppState
import GroupTable
import DocumentRead
import Workflow


struct StackContentView: View {
    
    @State private var state: StateStore
    
    @State private var container: DIContainer
    @State private var destinations = [Destination]()
    @State private var alertMessage: String = ""
    @State private var hasAlert: Bool = false
    @State private var searchContent: String = ""
    @State private var isSearchActive = false
    
    
    init(state: StateStore) {
        self.state = state
        self.container = DIContainer(state: state)
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: container.c.resolve(TreeViewModel.self)!)
                .frame(minWidth: 180,idealWidth: 200)
        }detail: {
            NavigationStack(path: $destinations) {
                
                StackBannerView()
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .groupList(group: let group):
                            GroupTableView(groupID: group, viewModel: container.c.resolve(GroupTableViewModel.self)!)
                                .id(group)
                            
                        case .listDocuments(prespective: let prespective):
                            DocumentListView(viewModel: container.c.resolve(DocumentListViewModel.self, name: prespective.Title)!).id(prespective).navigationTitle(prespective.Title)
                        case .readDocument(document: let document):
                            DocumentReadView(viewModel: container.c.resolve(DocumentReadViewModel.self, argument: document)!).id(document)
                            
                        case .workflowDashboard:
                            WorkflowListView(viewModel: container.c.resolve(WorkflowListViewModel.self)!)
                        case .workflowDetail(workflow: let workflow):
                            WorkflowDetailView(viewModel: container.c.resolve(WorkflowDetailViewModel.self, argument: workflow)!).id(workflow)
                        case .searchDocuments:
                            SearchView(search: searchContent, viewModel: container.c.resolve(SearchViewModel.self)!)
                        default:
                            Text("unknown destination")
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .setDestination)) { [self] notification in
            if let ds = notification.object as? [Destination] {
                self.destinations.removeAll()
                for d in ds {
                    self.destinations.append(d)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gotoDestination)) { [self] notification in
            if let dest = notification.object as? Destination {
                self.destinations.append(dest)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("alert"))) { [self] notification in
            if let msg = notification.object as? String {
                alertMessage = msg
                hasAlert = true
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .principal){
                BackgroundJobView(state: state)
                NotificationView(state: state)
                Spacer()
            }
            
        }
        .searchable(text: $searchContent)
        .onSubmit(of: .search) {
            isSearchActive = true
            destinations.append(.searchDocuments)
        }
        .alert(alertMessage, isPresented: $hasAlert){
            Button("OK", role: .cancel) {}
        }
    }
}

struct StackBannerView: View {
    var body: some View {
        VStackLayout(alignment: .leading){
            Text(" _")
            Text("//\\")
            Text("V  \\")
            Text(" \\  \\_")
            Text("  \\,'.`-.")
            Text("   |\\ `. `.")
            Text("   ( \\  `. `-.                        _,.-:\\")
            Text("    \\ \\   `.  `-._             __..--' ,-';/")
            Text("     \\ `.   `-.   `-..___..---'   _.--' ,'/")
            Text("      `. `.    `-._        __..--'    ,' /")
            Text("        `. `-_     ``--..''       _.-' ,'")
            Text("          `-_ `-.___        __,--'   ,'")
            Text("             `-.__  `----\"\"\"    __.-'")
            Text("                  `--..____..--'")
        }
        .font(.system(size: 14, weight: .thin, design: .monospaced)).foregroundColor(.gray)
    }
}
