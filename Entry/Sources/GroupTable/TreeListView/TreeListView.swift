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


@available(macOS 14.0, *)
struct TreeListView: View {
    @State private var viewModel: TreeViewModel
    
    public init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        OutlineGroup(viewModel.groupTree.children ?? [], children: \.children){ child in
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
        .contextMenu{
            // TODO: set selected entry
            MenuView(parentID: -1, viewModel: viewModel)
        }
    }
}



#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        List{
            TreeListView(viewModel: TreeViewModel(store: StateStore.empty, treeUsecase: MockEntryTreeUseCase(), entryUsecase: MockEntryUseCase()))
        }
    }
}

#endif
