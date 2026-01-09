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
    @State private var groupTree = GroupTree.shared
    @State private var target: EntryGroup
    @State private var targetDetail: EntryDetail?
    @State private var viewModel: TreeViewModel

    public init(target: EntryGroup, viewModel: TreeViewModel) {
        self.target = target
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if canCreateGroup(){
                Section{
                    Menu("New") {
                        Button("EntryGroup", action: {
                            // show create group form
                            NotificationCenter.default.post(
                                name: NSNotification.Name.createGroupInTree,
                                object: NewGroupRequest(parentUri: target.uri, groupType: .standard))
                        })
                        Button("RSS Feed", action: {
                            // show create rss form
                            NotificationCenter.default.post(
                                name: NSNotification.Name.createGroupInTree,
                                object: NewGroupRequest(parentUri: target.uri, groupType: .feed))
                        })
                        Button("Dynamic EntryGroup", action: {
                            NotificationCenter.default.post(
                                name: NSNotification.Name.createGroupInTree,
                                object: NewGroupRequest(parentUri: target.uri, groupType: .dynamic))
                        })
                    }
                }
            }

            if canBeEdit() {
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
                        ForEach(groupTree.children ?? []){ childGroup in
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
    }

    func canCreateGroup() -> Bool {
        return !isInternalFile(target)
    }

    func canBeEdit() -> Bool {
        return target.id != groupTree.root.id && !isInternalFile(target)
    }

    func moveEntriesToGroup(newParentUri: String) {
        Task {
            let _ = await viewModel.moveEntriesToGroup(entryUris: [target.uri], newParentUri: newParentUri)
        }
    }
}
