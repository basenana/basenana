//
//  StackContentView.swift
//  basenana
//
//  Created by Hypo on 2024/6/20.
//

import SwiftUI
import Foundation


struct StackContentView: View {
    @Environment(Store.self) private var store: Store
    
    @State private var navPath = NavigationPath()
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .frame(minWidth: 180,idealWidth: 200)
        }detail: {
            NavigationStack(path: store.binding(for: \.destinations, toAction: { .setDestination(to: $0)})) {
                if let selection = store.state.sidebarSelection {
                    StackLandingView(landing: selection)
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .groupList(group: let group):
                            GroupView(group: group).id(group).navigationTitle(group.groupName)
                        default:
                            Text("unknown destination")
                        }
                    }
                } else {
                    StackBannerView()
                }
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction){
                Spacer()
                BackgroundJobView()
                NotificationView()
            }
        }
        .searchable(text: store.binding(for: \.search.query, toAction: { _ in .alert(msg: "not support") } ))
        .sheet(item: store.binding(for: \.showSheet, toAction: { .showSheet(sheetKind: $0) })){ item in
            switch item{
            case .quickInbox:
                QuickInboxView()
            case .createGroup(parent: let parent, grpType: let grpType):
                GroupCreateView(parent: parent, groupType: grpType)
            }
        }
        .alert(store.state.alert.alertMessage, isPresented: store.binding(for: \.alert.needAlert, toAction: { _ in .offAlert })){
            Button("OK", role: .cancel) {}
        }
    }
}


struct StackLandingView: View {
    var landing: Destination
    
    var body: some View {
        switch landing {
        case .readDocuments(prespective: let prespective):
            DocumentView(prespective: prespective).id(prespective).navigationTitle(prespective.Title)
        case .groupList(group: let group):
            GroupView(group: group).id(group).navigationTitle(group.groupName)
        default:
            Text("unknown")
        }
    }
}

enum SheetKind: Identifiable{
    case quickInbox
    case createGroup(parent: GroupModel?, grpType: GroupType)
    
    var id: String {
        get {
            switch self {
            case .quickInbox:
                return "kind_quick_inbox"
                case .createGroup(parent: let parent, grpType: let grpType):
                return "kind_\(parent?.groupID ?? 0)_\(grpType.id)"
            }
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
