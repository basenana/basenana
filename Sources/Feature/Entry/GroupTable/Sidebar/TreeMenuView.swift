//
//  TreeMenuView.swift
//  Entry
//
//  Created by Hypo on 2024/10/10.
//

import Foundation
import SwiftUI
import Domain


struct TreeMenuView: View {
    @Environment(\.stateStore) private var store
    @State private var target: EntryGroup
    @State private var targetDetail: EntryDetail?
    @State private var viewModel: TreeViewModel

    public init(target: EntryGroup, viewModel: TreeViewModel) {
        self.target = target
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            Section{
                Button("New Group") {
                    // show create group form
                    NotificationCenter.default.post(
                        name: NSNotification.Name.createGroupInTree,
                        object: NewGroupRequest(parentUri: target.uri, groupType: .standard))
                }
            }

            Section{
                Button("Rename", action: {
                    NotificationCenter.default.post(
                        name: NSNotification.Name.renameGroupInTree,
                        object: target.uri)
                })
                Button("Delete", action: {
                    NotificationCenter.default.post(
                        name: NSNotification.Name.deleteGroupInTree,
                        object: [target.uri])
                })
            }

            Section{
                Menu("Move To") {
                    ForEach(store?.treeChildren ?? []){ childGroup in
                        GroupDestinationView(
                            group: childGroup,
                            childKeyPath: \.children,
                            action: { moveEntriesToGroup(newParentUri: $0.uri ) }
                        )
                    }
                }
            }

        }
    }

    func moveEntriesToGroup(newParentUri: String) {
        Task {
            let _ = await viewModel.moveEntriesToGroup(entryUris: [target.uri], newParentUri: newParentUri)
        }
    }
}
