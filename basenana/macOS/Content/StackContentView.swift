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
    @State private var siderbarSelection: Destination = .mainContent
    @State private var alertMessage: String = ""
    @State private var hasAlert: Bool = false


    init(state: StateStore) {
        self.state = state
        self.container = DIContainer(state: state)
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: container.c.resolve(TreeViewModel.self)!)
                .frame(minWidth: 180,idealWidth: 200)
        }detail: {
            NavigationStack(path: state.binding(for: \.destinations, toAction: { .setDestination(to: $0)})) {
                
                SidebarContentView(landing: siderbarSelection, container: $container)
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .groupList(group: let group):
                            GroupTableView(groupID: group, viewModel: container.c.resolve(GroupTableViewModel.self)!)
                                .id(group)
                        case .readDocument(document: let document):
                            DocumentReadView(viewModel: container.c.resolve(DocumentReadViewModel.self, argument: document)!).id(document)
                        case .workflowDetail(workflow: let workflow):
                            WorkflowDetailView(viewModel: container.c.resolve(WorkflowDetailViewModel.self, argument: workflow)!).id(workflow)
                        default:
                            Text("unknown destination")
                        }
                    }
            }
        }
        .onAppear{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("selectSidebar"), object: nil)
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("selectSidebar"),
                object: nil,
                queue: .main) { [self] notification in
                    if let s = notification.object as? Destination {
                        self.siderbarSelection = s
                    }
                }
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("alert"), object: nil)
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("alert"),
                object: nil,
                queue: .main) { [self] notification in
                    if let msg = notification.object as? String {
                        alertMessage = msg
                        hasAlert = true
                    }
                }
        }
        .onDisappear(){
            NotificationCenter.default.removeObserver(self)
        }
        .toolbar{
            ToolbarItemGroup(placement: .principal){
                BackgroundJobView(state: state)
                NotificationView(state: state)
                Spacer()
            }
        }
        .alert(alertMessage, isPresented: $hasAlert){
            Button("OK", role: .cancel) {}
        }
    }
}


struct SidebarContentView: View {
    var landing: Destination
    @Binding var container: DIContainer
    
    var body: some View {
        switch landing {
        case .mainContent:
            StackBannerView()
        case .listDocuments(prespective: let prespective):
            DocumentListView(viewModel: container.c.resolve(DocumentListViewModel.self, name: prespective.Title)!).id(prespective).navigationTitle(prespective.Title)
        case .groupList(group: let group):
            GroupTableView(groupID: group, viewModel: container.c.resolve(GroupTableViewModel.self)!).id(group)
        case .workflowDashboard:
            WorkflowListView(viewModel: container.c.resolve(WorkflowListViewModel.self)!)
        default:
            Text("unknown")
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
