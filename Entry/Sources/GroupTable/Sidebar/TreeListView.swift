//
//  TreeListView.swift
//
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI
import Entities
import AppState
import SwiftData


struct TreeListView: View {
    @State private var groupTree = GroupTree.shared
    @State private var viewModel: TreeViewModel
    
    public init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        OutlineGroup(groupTree.children ?? [], children: \.children){ child in
            NavigationLink(value: Destination.groupList(group: child.id), label: {
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
                    let _ = await viewModel.moveEntriesToGroup(entryURLs: urls, newParent: child.id)
                }
                return true
            }
            .draggable(EntryUrl(entryID: child.id))
        }
    }
}



#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        List{
            TreeListView(viewModel: TreeViewModel(store: StateStore.shared, entryUsecase: MockEntryUseCase()))
        }
    }
}

#endif
