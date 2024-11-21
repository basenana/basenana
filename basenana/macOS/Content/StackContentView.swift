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


struct StackContentView: View {
    
    @State private var state: StateStore
    @Binding private var environment: Environment
    @State private var container: DIContainer

    init(state: StateStore, environment: Binding<Environment>) {
        self.state = state
        self._environment = environment
        self.container = DIContainer(state: state, environment: environment.wrappedValue)
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: container.c.resolve(TreeViewModel.self)!)
                .frame(minWidth: 180,idealWidth: 200)
        }detail: {
            NavigationStack(path: state.binding(for: \.destinations, toAction: { .setDestination(to: $0)})) {
                
                SidebarContentView(landing: state.sidebarSelection, container: $container)
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .groupList(group: let group):
                            GroupTableView(groupID: group, viewModel: container.c.resolve(TreeViewModel.self)!)
                                .id(group)
                        case .readDocument(document: let document):
                            DocumentReadView(viewModel: container.c.resolve(DocumentReadViewModel.self, argument: document)!).id(document)
                        case .workflowDashboard:
//                            WorkflowView()
                            Text("workflow")
                        default:
                            Text("unknown destination")
                        }
                    }
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .principal){
                BackgroundJobView(state: state)
                NotificationView(state: state)
                Spacer()
            }
        }
        .alert(state.alert.alertMessage, isPresented: state.binding(for: \.alert.needAlert, toAction: { _ in .alert(msg: nil) })){
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
            GroupTableView(groupID: group, viewModel: container.c.resolve(TreeViewModel.self)!).id(group)
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
