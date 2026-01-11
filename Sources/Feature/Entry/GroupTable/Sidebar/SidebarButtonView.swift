//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI
import Domain
import Domain
import Styleguide

struct SidebarButtonView: View {
    @State private var viewModel: TreeViewModel
    @Bindable var groupTree = GroupTree.shared

    @State private var showCreateGroup: Bool = false
    @State private var createGroupInParentUri: String = ""
    @State private var createGroupType: GroupType = .standard

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

            Menu {
                Button("EntryGroup", action: {
                    let parentUri = viewModel.selectedGroupUri ?? groupTree.root.uri
                    NotificationCenter.default.post(
                        name: NSNotification.Name.createGroupInTree,
                        object: NewGroupRequest(parentUri: parentUri, groupType: .standard))
                })
                Button("RSS Feed", action: {
                    let parentUri = viewModel.selectedGroupUri ?? groupTree.root.uri
                    NotificationCenter.default.post(
                        name: NSNotification.Name.createGroupInTree,
                        object: NewGroupRequest(parentUri: parentUri, groupType: .feed))
                })
                Button("Dynamic EntryGroup", action: {
                    let parentUri = viewModel.selectedGroupUri ?? groupTree.root.uri
                    NotificationCenter.default.post(
                        name: NSNotification.Name.createGroupInTree,
                        object: NewGroupRequest(parentUri: parentUri, groupType: .dynamic))
                })
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            .menuIndicator(.hidden)
            .menuStyle(.button)
            .buttonStyle(.accessoryBar)

            Spacer()

            Button(action: {
                gotoDestination(Destination.workflowDashboard)
            }, label: {
                Image(systemName: "ellipsis.curlybraces")
            })
            .buttonStyle(.accessoryBar)
        })
        .sheet(isPresented: $showCreateGroup){
            GroupCreateView(
                parentUri: self.createGroupInParentUri,
                groupType: createGroupType,
                viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                showCreateGroup: $showCreateGroup)
        }
        .onReceive(NotificationCenter.default.publisher(for: .createGroupInTree)) { [self] notification in
            if let req = notification.object as? NewGroupRequest {
                self.createGroupInParentUri = req.parentUri
                self.createGroupType = req.groupType
                self.showCreateGroup.toggle()
            }
        }
        .onChange(of: self.createGroupInParentUri){}
        .onChange(of: self.createGroupType){}
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
            WebPackInboxView(viewModel: InboxViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase), showInboxView: $showQuickInbox)
        }
        .padding(5)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
    }
}

