//
//  GroupTableView.swift
//  Entry
//
//  Created by Hypo on 2024/10/14.
//

import os
import SwiftUI
import Foundation
import Domain
import Domain


public struct GroupTableView: View {
    @State private var groupUri: String
    @State private var groupName: String? = nil

    @State private var viewModel: GroupTableViewModel

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: GroupTableView.self)
        )

    public init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.groupName = ""
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            GroupTableWithSheetView(groupUri: groupUri, viewModel: viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .reopenGroup)) { [self] notification in
            if let uris = notification.object as? [String] {
                var needReopen = false
                for u in uris {
                    if u != groupUri {
                        continue
                    }
                    needReopen = true
                    break
                }

                if needReopen {
                    Task {
                        // reopen
                        await viewModel.openGroup(uri: groupUri)
                    }
                }
            }
        }
        .task {
            Self.logger.notice("open group \(groupUri)")
            await viewModel.openGroup(uri: groupUri)

            if let opg = viewModel.group {
                if opg.name == ".inbox" {
                    groupName = "Inbox"
                } else {
                    groupName = opg.name
                }
            }
        }
        .navigationTitle(groupName ?? "")
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction){
                FileToolBarView(viewModel: viewModel)
            }
        }
    }
}

private struct GroupTableWithSheetView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel

    @State private var showCreateGroup: Bool = false
    @State private var createGroupInParentUri: String = ""
    @State private var createGroupType: GroupType = .standard

    @State private var showDeleteConfirm: Bool = false
    @State private var needDeletedEnties: [String] = []

    @State private var showRenameEntry: Bool = false
    @State private var renameEntryUri: String = ""

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        GroupTableWithDropView(groupUri: groupUri, viewModel: viewModel)
            .sheet(isPresented: $showCreateGroup){
                GroupCreateView(
                    parentUri: createGroupInParentUri,
                    groupType: createGroupType,
                    viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                    showCreateGroup: $showCreateGroup)
            }
            .onReceive(NotificationCenter.default.publisher(for: .createGroup)) { [self] notification in
                if let req = notification.object as? NewGroupRequest {
                    self.createGroupInParentUri = req.parentUri
                    self.createGroupType = req.groupType
                    self.showCreateGroup.toggle()
                }
            }
            .onChange(of: createGroupInParentUri){}
            .onChange(of: createGroupType){}

            .sheet(isPresented: $showRenameEntry){
                EntryRenameView(
                    entryUri: renameEntryUri,
                    viewModel: EntryDetailViewModel(
                        store: viewModel.store,entryUsecase: viewModel.entryUsecase),
                    showRenameView: $showRenameEntry)
            }
            .onReceive(NotificationCenter.default.publisher(for: .renameEntry)) { [self] notification in
                if let uri = notification.object as? String {
                    self.renameEntryUri = uri
                    self.showRenameEntry.toggle()
                }
            }
            .onChange(of: renameEntryUri){}

            .sheet(isPresented: $showDeleteConfirm){
                DeleteEntriesView(
                    entryUris: needDeletedEnties,
                    viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                    showDeleteView: $showDeleteConfirm)
            }
            .onReceive(NotificationCenter.default.publisher(for: .deleteEntry)) { [self] notification in
                if let uris = notification.object as? [String] {
                    self.needDeletedEnties = uris
                    self.showDeleteConfirm.toggle()
                }
            }
            .onChange(of: needDeletedEnties){}
    }
}


private struct GroupTableWithDropView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        GroupTableWithMenuView(groupUri: groupUri, viewModel: viewModel)
            .dropDestination(for: URL.self){ urls, _  in
                Task {
                    await viewModel.moveEntriesToGroup(entryURLs: urls, newParentUri: groupUri)
                }
                return true
            }
    }
}

private struct GroupTableWithMenuView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        GroupTableContentView(groupUri: groupUri, viewModel: viewModel)
            .contextMenu{
                EntryMenuView(viewModel: viewModel)
            }
            .contextMenu(forSelectionType: EntryRow.ID.self) { items in
                EntryMenuView(viewModel: viewModel)
            } primaryAction: { items in
                if  items.count == 1 {
                    if let grp = viewModel.children.filter({$0.id == items.first! && $0.isGroup}).first{
                        gotoDestination(.groupList(groupUri: grp.uri))
                    }
                }
            }
    }
}

private struct GroupTableContentView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel
    @State private var order: [KeyPathComparator<EntryRow>] = [.init(\.name, order: .forward)]

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            Table(of: EntryRow.self, selection: $viewModel.selection, sortOrder: $order) {
            TableColumn("Name", value: \.name) { entry in
                HStack {
                    Image(systemName: entry.isGroup ? "folder" : "doc.text")
                        .frame(width: 12, alignment: .center)
                    Text("\(entry.name)")
                }
            }
            TableColumn("Kind", value: \.kind)
            TableColumn("Size", value: \.size) {
                if $0.isGroup {
                    Text("--")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    Text($0.readableSize)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            TableColumn("Date Modified", value: \.modifiedAt) {
                Text("\($0.modifiedAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
            }
        } rows: {
            ForEach(viewModel.children, id: \.id) { child in
                if child.isGroup{

                    TableRow(child)
                        .draggable(EntryUri(uri: child.uri))
                        .dropDestination(for: URL.self){ urls in
                            Task {
                                let _ = await viewModel.moveEntriesToGroup(entryURLs: urls, newParentUri: child.uri)
                            }
                        }
                } else {

                    TableRow(child)
                        .draggable(EntryUri(uri: child.uri))
                }
            }
        }
        .onChange(of: order){
            withAnimation {
                viewModel.children.sort(using: order)
            }
        }

        if viewModel.hasMore {
            ProgressView()
                .padding()
                .onAppear {
                    Task {
                        await viewModel.loadNextPage()
                    }
                }
        }
        }
    }
}




func bytesToHumanReadableString(bytes: Int64) -> String {
    let kilobyte: Int64 = 1024
    let megabyte = kilobyte * 1024
    let gigabyte = megabyte * 1024
    let terabyte = gigabyte * 1024
    
    if bytes < kilobyte {
        return "\(bytes) B"
    } else if bytes < megabyte {
        return String(format: "%.2f KB", Double(bytes) / Double(kilobyte))
    } else if bytes < gigabyte {
        return String(format: "%.2f MB", Double(bytes) / Double(megabyte))
    } else if bytes < terabyte {
        return String(format: "%.2f GB", Double(bytes) / Double(gigabyte))
    } else {
        return String(format: "%.2f TB", Double(bytes) / Double(terabyte))
    }
}
