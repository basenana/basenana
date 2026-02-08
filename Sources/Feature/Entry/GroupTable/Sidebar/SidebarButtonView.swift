//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI
import Domain
import Styleguide

struct SidebarButtonView: View {
    @State private var viewModel: TreeViewModel
    @Environment(\.stateStore) private var store

    @State private var showCreateGroup: Bool = false
    @State private var createGroupParentUri: String = ""

    @State private var showQuickInbox: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var needDeletedEnties: [String] = []

    @State private var showRenameEntry: Bool = false
    @State private var renameEntryUri: String = ""

    init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(content: {
            Button(action: {
                showQuickInbox.toggle()
            }, label: {
                Image(systemName: "tray.and.arrow.down")
            })
            .buttonStyle(.accessoryBar)

            Button(action: {
                createGroupParentUri = defaultParentUri
                showCreateGroup.toggle()
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)

            Spacer()

            Button(action: {
                resetDestination(.workflowDashboard)
            }, label: {
                Image(systemName: "ellipsis.curlybraces")
            })
            .buttonStyle(.accessoryBar)
        })
        .sheet(isPresented: $showCreateGroup){
            GroupCreateView(
                parentUri: createGroupParentUri,
                groupType: .standard,
                viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                store: viewModel.store,
                showCreateGroup: $showCreateGroup)
        }
        .sheet(isPresented: $showDeleteConfirm){
            DeleteEntriesView(
                entryUris: self.needDeletedEnties,
                viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                showDeleteView: $showDeleteConfirm)
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteGroupInTree)) { [self] notification in
            if let uris = notification.object as? [String] {
                self.needDeletedEnties = uris
                self.showDeleteConfirm.toggle()
            }
        }
        .onChange(of: self.needDeletedEnties){}
        .onReceive(NotificationCenter.default.publisher(for: .createGroupInTree)) { [self] notification in
            if let req = notification.object as? NewGroupRequest {
                self.createGroupParentUri = req.parentUri
                self.showCreateGroup.toggle()
            }
        }
        .sheet(isPresented: $showRenameEntry){
            EntryRenameView(
                entryUri: renameEntryUri,
                viewModel: EntryDetailViewModel(
                    store: viewModel.store,entryUsecase: viewModel.entryUsecase),
                showRenameView: $showRenameEntry)
        }
        .onReceive(NotificationCenter.default.publisher(for: .renameGroupInTree)) { [self] notification in
            if let uri = notification.object as? String {
                self.renameEntryUri = uri
                self.showRenameEntry.toggle()
            }
        }
        .onChange(of: self.renameEntryUri){}
        .sheet(isPresented: $showQuickInbox){
            QuickInboxView(viewModel: InboxViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase), showInboxView: $showQuickInbox)
        }
        .padding(5)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
    }

    /// Calculate the default parent URI for new group creation
    /// - If selected group is a hidden folder (starts with "."), use root
    /// - Otherwise use the selected group URI
    /// - If nothing is selected, use the first visible child of root
    private var defaultParentUri: String {
        if let selected = viewModel.selectedGroupUri {
            // Check if selected group is hidden (starts with ".")
            let groupName = selected.split(separator: "/").last.map(String.init) ?? ""
            if groupName.hasPrefix(".") {
                return EntryURI.root
            }
            return selected
        }

        // No selection: use first visible child of root
        return store?.rootGroup?.children?
            .first(where: { !$0.groupName.hasPrefix(".") })?
            .uri ?? ""
    }
}
