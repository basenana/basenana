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
import MenuView


@available(macOS 14.0, *)
struct TreeListView: View {
    @State private var viewModel: TreeViewModel
    
    public init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack{
            OutlineGroup(viewModel.store.groupTree.children ?? [], children: \.children){ child in
                NavigationLink(value: Destination.groupList(group: child.id), label: {
                    HStack{
                        Image(systemName: "folder")
                        Text("\(child.groupName)")
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                })
                .id(child.id)
                .dropDestination(for: String.self){ entryIDInfos, localtion in
                    viewModel.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryIDInfos), newParent: child.id)
                    return false
                }
                .draggable(IDHelper(kind: "group", id: child.id).Encode())
            }
        }
        .task {
            viewModel.resetGroupTree()
        }
        .contextMenu{
            // TODO: set selected entry
            MenuView(viewModel: MenuViewModel(store: viewModel.store, entry: nil))
        }
    }
}



#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        List{
            TreeListView(viewModel: TreeViewModel(store: StateStore.empty, entryTreeUserCase: MockEntryTreeUseCase()))
        }
    }
}

#endif
