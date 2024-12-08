//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI
import Entities
import AppState
import Styleguide

struct SidebarButtonView: View {
    @State private var viewModel: TreeViewModel
    @State private var groupTree = GroupTree.shared
    
    @State private var showCreateGroup: Bool = false
    @State private var createGroupInParent: Int64 = -1
    @State private var createGroupType: GroupType = .standard
    
    @State private var showQuickInbox: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var needDeletedEnties: [Int64] = []
    
    @State private var showRenameEntry: Bool = false
    @State private var renameEntry: Int64 = -1
    
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
                if let s = viewModel.selectedGroupId {
                    NotificationCenter.default.post(
                        name: NSNotification.Name.createGroupInTree,
                        object: NewGroupRequest(parent: s, groupType: .standard))
                } else {
                    NotificationCenter.default.post(
                        name: NSNotification.Name.createGroupInTree,
                        object: NewGroupRequest(parent: groupTree.root.id, groupType: .standard))
                }
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)
            
            Spacer()
            
            Button(action: {
                NotificationCenter.default.post(name: NSNotification.Name("selectSidebar"), object: Destination.workflowDashboard)
            }, label: {
                Image(systemName: "ellipsis.curlybraces")
            })
            .buttonStyle(.accessoryBar)
        })
        .sheet(isPresented: $showCreateGroup){
            GroupCreateView(
                parent: self.createGroupInParent,
                groupType: createGroupType,
                viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                showCreateGroup: $showCreateGroup)
        }
        .onReceive(NotificationCenter.default.publisher(for: .createGroupInTree)) { [self] notification in
            if let req = notification.object as? NewGroupRequest {
                self.createGroupInParent = req.parent
                self.createGroupType = req.groupType
                self.showCreateGroup.toggle()
            }
        }
        .onChange(of: self.createGroupInParent){}
        .onChange(of: self.createGroupType){}
        .sheet(isPresented: $showDeleteConfirm){
            DeleteEntriesView(
                entryIDs: self.needDeletedEnties,
                viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                showDeleteView: $showDeleteConfirm)
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteGroupInTree)) { [self] notification in
            if let entries = notification.object as? [Int64] {
                self.needDeletedEnties = entries
                self.showDeleteConfirm.toggle()
            }
        }
        .onChange(of: self.needDeletedEnties){}
        .sheet(isPresented: $showRenameEntry){
            EntryRenameView(
                entry: renameEntry,
                viewModel: EntryDetailViewModel(
                    store: viewModel.store,entryUsecase: viewModel.entryUsecase),
                showRenameView: $showRenameEntry)
        }
        .onReceive(NotificationCenter.default.publisher(for: .renameGroupInTree)) { [self] notification in
            if let gid = notification.object as? Int64 {
                self.renameEntry = gid
                self.showRenameEntry.toggle()
            }
        }
        .onChange(of: self.renameEntry){}
        .sheet(isPresented: $showQuickInbox){
            //            QuickInboxView(viewModel: InboxViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase))
            WebPackInboxView(viewModel: InboxViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase), showInboxView: $showQuickInbox)
        }
        .padding(5)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
    }
}

