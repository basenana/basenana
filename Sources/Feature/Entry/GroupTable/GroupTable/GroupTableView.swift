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
import Data


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
        VStack(spacing: 0) {
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

            ToolbarItemGroup(placement: .secondaryAction){
                Button {
                    viewModel.store.showDocumentView.toggle()
                } label: {
                    Image(systemName: "doc.text.image")
                        .foregroundStyle(viewModel.store.showDocumentView ? Color.accentColor : Color.primary)
                }
                .help("Toggle Document View")

                Button {
                    viewModel.store.showInspector.toggle()
                } label: {
                    Image(systemName: "sidebar.right")
                        .foregroundStyle(viewModel.store.showInspector ? Color.accentColor : Color.primary)
                }
                .help("Toggle Inspector")
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
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    tableContent

                    if viewModel.showDocumentView {
                        documentViewSection
                    }
                }

                if viewModel.showInspector {
                    inspectorSection
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
        .onChange(of: viewModel.selection) { _, _ in
            Task {
                await viewModel.loadSelectedEntryDetail()
            }
        }
    }

    private var tableContent: some View {
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
                if child.isGroup {
                    TableRow(child)
                        .draggable(EntryUri(uri: child.uri))
                        .dropDestination(for: URL.self) { urls in
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
        .onChange(of: order) {
            withAnimation {
                viewModel.children.sort(using: order)
            }
        }
    }

    @ViewBuilder
    private var inspectorSection: some View {
        if let entry = viewModel.selectedEntryDetail {
            Divider()
            InspectorView(entry: entry)
                .frame(width: 280)
                .background(Color(NSColor.controlBackgroundColor))
        }
    }

    @ViewBuilder
    private var documentViewSection: some View {
        if let entry = viewModel.selectedEntryDetail {
            Divider()
            ResizableDocumentView(entry: entry, viewModel: viewModel)
                .frame(height: viewModel.documentViewHeight)
        }
    }
}


private struct ResizableDocumentView: View {
    let entry: EntryDetail
    let viewModel: GroupTableViewModel

    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
            documentContent
        }
    }

    private var dragHandle: some View {
        Rectangle()
            .fill(isDragging ? Color(NSColor.selectedControlColor) : Color(NSColor.separatorColor))
            .frame(height: 4)
            .overlay(alignment: .center) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(NSColor.disabledControlTextColor).opacity(0.5))
                    .frame(width: 30, height: 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let newHeight = viewModel.documentViewHeight - value.translation.height
                        viewModel.documentViewHeight = min(
                            max(newHeight, viewModel.minDocumentViewHeight),
                            viewModel.maxDocumentViewHeight
                        )
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeUpDown.push()
                } else {
                    NSCursor.pop()
                }
            }
    }

    private var documentContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Document: \(entry.documentTitle ?? entry.name)")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if let uri = viewModel.selectedEntryDetail?.uri {
                DocumentReadContainerView(entryUri: uri, store: viewModel.store, fileRepository: viewModel.fileRepository, documentUsecase: viewModel.documentUsecase)
                    .id(uri)
                    .frame(maxHeight: .infinity)
            } else {
                Text("No document selected")
                    .frame(maxHeight: .infinity)
            }
        }
    }
}


private struct DocumentReadContainerView: View {
    let entryUri: String
    let store: StateStore
    let fileRepository: FileRepositoryProtocol
    let documentUsecase: any DocumentUseCaseProtocol

    @State private var viewModel: DocumentReadViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                DocumentReadView(viewModel: vm)
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        viewModel = DocumentReadViewModel(
                            uri: entryUri,
                            store: store,
                            usecase: documentUsecase,
                            fileRepository: fileRepository
                        )
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

private struct InspectorView: View {
    let entry: EntryDetail

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                basicInfoSection
                Divider()
                timeInfoSection
                Divider()
                documentInfoSection
                Divider()
                propertiesSection
            }
            .padding()
        }
        .frame(minWidth: 260)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Basic")
                .font(.headline)
                .foregroundColor(.secondary)

            InspectorPropertyRow(label: "Name", value: entry.name)
            InspectorPropertyRow(label: "Kind", value: entry.kind)
            InspectorPropertyRow(label: "Size", value: bytesToHumanReadableString(bytes: entry.size))
            InspectorPropertyRow(label: "URI", value: entry.uri)
            InspectorPropertyRow(label: "Is Group", value: entry.isGroup ? "Yes" : "No")

            if let storage = entry.storage {
                InspectorPropertyRow(label: "Storage", value: storage)
            }
            if let ns = entry.namespace {
                InspectorPropertyRow(label: "Namespace", value: ns)
            }
        }
    }

    private var timeInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time")
                .font(.headline)
                .foregroundColor(.secondary)

            InspectorPropertyRow(label: "Created", value: formatDate(entry.createdAt))
            InspectorPropertyRow(label: "Changed", value: formatDate(entry.changedAt))
            InspectorPropertyRow(label: "Modified", value: formatDate(entry.modifiedAt))
            InspectorPropertyRow(label: "Accessed", value: formatDate(entry.accessAt))
        }
    }

    private var documentInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Document")
                .font(.headline)
                .foregroundColor(.secondary)

            if let title = entry.documentTitle {
                InspectorPropertyRow(label: "Title", value: title)
            }
            if let author = entry.documentAuthor {
                InspectorPropertyRow(label: "Author", value: author)
            }
            if let year = entry.documentYear {
                InspectorPropertyRow(label: "Year", value: year)
            }
            if let source = entry.documentSource {
                InspectorPropertyRow(label: "Source", value: source)
            }
            if let abstract = entry.documentAbstract {
                InspectorPropertyRow(label: "Abstract", value: abstract)
            }
            if let notes = entry.documentNotes {
                InspectorPropertyRow(label: "Notes", value: notes)
            }
            if let url = entry.documentURL {
                InspectorPropertyRow(label: "URL", value: url)
            }
            if let keywords = entry.documentKeywords, !keywords.isEmpty {
                InspectorPropertyRow(label: "Keywords", value: keywords.joined(separator: ", "))
            }

            InspectorPropertyRow(label: "Marked", value: entry.documentMarked ? "Yes" : "No")
            InspectorPropertyRow(label: "Unread", value: entry.documentUnread ? "Yes" : "No")

            if let siteName = entry.documentSiteName {
                InspectorPropertyRow(label: "Site Name", value: siteName)
            }
            if let siteURL = entry.documentSiteURL {
                InspectorPropertyRow(label: "Site URL", value: siteURL)
            }
        }
    }

    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Properties")
                .font(.headline)
                .foregroundColor(.secondary)

            ForEach(entry.properties, id: \.key) { property in
                InspectorPropertyRow(label: property.key, value: property.value, isEncoded: property.encoded)
            }

            if entry.properties.isEmpty {
                Text("No properties")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


private struct InspectorPropertyRow: View {
    let label: String
    let value: String
    var isEncoded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .lineLimit(3)
                .textSelection(.enabled)
        }
    }
}
