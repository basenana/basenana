//
//  TreeListView.swift
//
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI
import Domain
import Domain
import SwiftData


struct TreeListView: View {
    @State private var viewModel: TreeViewModel
    @Environment(\.stateStore) private var store

    public init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        OutlineGroup(store?.treeChildren ?? [], children: \.children){ child in
            NavigationLink(value: Destination.groupList(groupUri: child.uri), label: {
                HStack{
                    Image(systemName: "folder")
                    Text("\(child.groupName)")
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 4)
            })
            .contextMenu{
                TreeMenuView(target: child.group, viewModel: viewModel)
            }
            .id(child.id)
            .dropDestination(for: URL.self){ urls, _ in
                Task {
                    let _ = await viewModel.moveEntriesToGroup(entryURLs: urls, newParentUri: child.uri)
                }
                return true
            }
            .draggable(EntryUri(uri: child.group.uri))
        }
    }
}

