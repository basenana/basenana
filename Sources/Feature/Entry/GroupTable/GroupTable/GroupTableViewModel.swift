//
//  GroupTableViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/27.
//

import os
import SwiftUI
import Domain
import Domain
import Domain


@Observable
@MainActor
public class GroupTableViewModel: BaseViewModel {

    // MARK: - Local Children Cache
    private var _children: [CachedEntry] = []

    var children: [EntryRow] {
        _children.map { EntryRow(from: $0) }
    }

    func resetChildren() {
        _children = []
    }

    func appendChildren(_ items: [CachedEntry]) {
        _children.append(contentsOf: items)
    }

    func sortChildrenInternal(by areInIncreasingOrder: (CachedEntry, CachedEntry) -> Bool) {
        _children.sort(by: areInIncreasingOrder)
    }

    // MARK: - State from Store
    var group: EntryDetail? {
        get { _group }
        set {
            if _group?.uri != newValue?.uri {
                _group = newValue
                resetChildren()
                resetPagination()
            }
        }
    }

    // MARK: - Local State
    var page: Int = 1
    var pageSize: Int = 50
    var hasMore: Bool = true
    var isLoading: Bool = false
    private var _group: EntryDetail? = nil

    // Local currentGroupUri to avoid relying on global Store state
    var currentGroupUri: String = ""

    // Internal selection storage
    private var _selection: Set<EntryRow.ID> = [] {
        didSet {
            updateSelectionState()
        }
    }

    // Exposed selection property
    var selection: Set<EntryRow.ID> {
        get { _selection }
        set { _selection = newValue }
    }

    var selectedDocument: EntryDetail? = nil

    // Panel visibility states (from global StateStore)
    var showInspector: Bool { store.showInspector }
    var showDocumentView: Bool { store.showDocumentView }
    var selectedEntryDetail: EntryDetail? = nil
    var selectedGroupConfig: GroupConfig? = nil

    // Inspector displays either selected entry detail or current group detail
    var inspectorEntryDetail: EntryDetail? {
        selectedEntryDetail ?? group
    }

    // Inspector displays either selected entry's group config or current group's config
    var inspectorGroupConfig: GroupConfig? {
        if selectedEntryDetail != nil {
            return selectedGroupConfig
        }
        return group.map { _ in selectedGroupConfig } ?? nil
    }

    // Document view height (resizable)
    var documentViewHeight: CGFloat = 500
    let minDocumentViewHeight: CGFloat = 100
    let maxDocumentViewHeight: CGFloat = 1000

    // Dependencies
    var fileRepository: FileRepositoryProtocol
    var documentUsecase: any DocumentUseCaseProtocol
    var fridayUseCase: FridayUseCaseProtocol
    private var syncUseCase: EntrySyncUseCase

    public init(store: StateStore, entryUsecase: any EntryUseCaseProtocol, fileRepository: FileRepositoryProtocol, documentUsecase: any DocumentUseCaseProtocol, fridayUseCase: FridayUseCaseProtocol, syncUseCase: EntrySyncUseCase) {
        self.fileRepository = fileRepository
        self.documentUsecase = documentUsecase
        self.fridayUseCase = fridayUseCase
        self.syncUseCase = syncUseCase
        super.init(store: store, entryUsecase: entryUsecase)
    }

    var selectedEntries: [EntryInfo] {
        get {
            children.filter( { selection.contains($0.id)} ).map({ $0.info })
        }
    }

    var canShowPanels: Bool {
        selection.count == 1 && {
            guard let id = selection.first,
                  let entry = children.first(where: { $0.id == id }) else {
                return false
            }
            return !entry.isGroup
        }()
    }

    // MARK: - Selection Change Handler
    private func updateSelectionState() {
        guard selection.count == 1, let id = selection.first,
              let entry = children.first(where: { $0.id == id }) else {
            store.selectedEntryUri = nil
            return
        }
        store.selectedEntryUri = entry.uri
    }

    // MARK: - Pagination Helper
    private func resetPagination() {
        page = 1
        hasMore = true
    }

    // MARK: - Child Access Helpers
    private func child(at id: EntryRow.ID) -> EntryRow? {
        children.first { $0.id == id }
    }

    private func index(of id: EntryRow.ID) -> Int? {
        children.firstIndex { $0.id == id }
    }

    func loadSelectedEntryDetail() async {
        // When nothing is selected, load current group's config for inspector
        guard selection.count == 1, let id = selection.first else {
            selectedEntryDetail = nil
            // Still load current group's config if available
            if let currentGroupUri = group?.uri {
                await loadGroupConfig(uri: currentGroupUri)
            } else {
                selectedGroupConfig = nil
            }
            return
        }

        guard let entry = child(at: id) else {
            selectedEntryDetail = nil
            selectedGroupConfig = nil
            return
        }

        do {
            selectedEntryDetail = try await entryUsecase.getEntryDetails(uri: entry.uri)
            // Load group config if it's a group
            if entry.isGroup {
                await loadGroupConfig(uri: entry.uri)
            } else {
                selectedGroupConfig = nil
            }
        } catch {
            sentAlert("load entry detail failed: \(error)")
            selectedEntryDetail = nil
            selectedGroupConfig = nil
        }
    }

    func reset() {
        resetPagination()
        resetChildren()
    }

    func loadNextPage() async {
        guard !isLoading && hasMore, let group = group else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let newChildren = try await entryUsecase.listChildren(uri: group.uri, page: page, pageSize: pageSize, sort: "name", order: "asc")
            if newChildren.isEmpty {
                hasMore = false
                return
            }

            let rows = newChildren.map { CachedEntry(from: $0) }
            appendChildren(rows)

            if newChildren.count < pageSize {
                hasMore = false
            } else {
                page += 1
                Task.detached { [weak self] in
                    await self?.loadNextPage()
                }
            }
        } catch {
            sentAlert("load more children failed: \(error)")
        }
    }

    func openGroup(uri: String) async {
        do {
            let detail = try await entryUsecase.getEntryDetails(uri: uri)
            if !detail.isGroup {
                throw BizError.notGroup
            }

            // Sync with local state
            currentGroupUri = uri
            group = detail

            resetPagination()
            resetChildren()
            await loadNextPage()
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("open group failed: \(error)")
        }
    }

    // MARK: - Synchronous Update Methods

    func updateChild(id: Int64, newName: String, newUri: String) {
        syncUseCase.syncChildrenAfterRename(id: id, newName: newName, newUri: newUri)
    }

    func removeChildren(ids: [Int64]) {
        let uris = _children.filter { ids.contains($0.id) }.map { $0.uri }
        syncUseCase.syncChildrenAfterDelete(parentUri: nil, uris: uris)
    }

    func sortChildren(by comparators: [KeyPathComparator<EntryRow>]) {
        // Sort in-place without triggering reset
        sortChildrenInternal { lhs, rhs in
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    func addChildren(infos: [EntryInfo]) {
        let parentUri = group?.uri ?? currentGroupUri
        syncUseCase.syncChildrenAfterCreate(parentUri: parentUri, entries: infos)
    }

    // MARK: - Wrapper Methods

    func moveChildrenToGroup(entryUris: [String], newParentUri: String) async -> Bool {
        let success = await moveEntriesToGroup(entryUris: entryUris, newParentUri: newParentUri)
        if success {
            syncUseCase.syncChildrenAfterMove(
                uris: entryUris,
                fromParent: group?.uri ?? currentGroupUri,
                toParent: newParentUri,
                currentGroupUri: currentGroupUri
            )
        }
        return success
    }

    func moveChildrenToGroup(entryURLs: [URL], newParentUri: String) async -> Bool {
        var entryUris: [String] = []
        var files = [URL]()

        for url in entryURLs {
            switch url.scheme {
            case "basenana":
                guard let targetUri = parseUriFromURL(url: url), !targetUri.isEmpty else {
                    sentAlert("\(url) not a valid entry")
                    continue
                }
                entryUris.append(targetUri)
            case "file":
                files.append(url)
            default:
                print("[moveChildrenToGroup] unknown url schema \(url)")
            }
        }

        if !entryUris.isEmpty {
            return await moveChildrenToGroup(entryUris: entryUris, newParentUri: newParentUri)
        }

        if !files.isEmpty {
            await uploadFilesToGroup(parentUri: newParentUri, files: files)
            return true
        }

        return false
    }

    private func parseUriFromURL(url: URL) -> String? {
        guard url.scheme == "basenana" else { return nil }
        var path = url.path
        if path.isEmpty {
            path = url.host ?? ""
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let id = queryItems.first(where: { $0.name == "id" })?.value {
            return "\(path)/\(id)"
        }
        return path.isEmpty ? nil : path
    }

    func renameEntry(entry: EntryDetail, newName: String) async -> Bool {
        let vm = EntryDetailViewModel(store: store, entryUsecase: entryUsecase)

        return await vm.renameEntry(entry: entry, newName: newName) { [self] id, newName, newUri in
            updateChild(id: id, newName: newName, newUri: newUri)
        }
    }

    func createGroup(parentUri: String, option: EntryCreate) async {
        let vm = CreateDeleteViewModel(store: store, entryUsecase: entryUsecase)

        await vm.createGroup(parentUri: parentUri, option: option) { [self] info in
            if group?.uri == parentUri {
                addChildren(infos: [info])
            }
        }
    }

    func deleteEntries(entries: [EntryInfo]) async {
        let uris = entries.map { $0.uri }
        let vm = CreateDeleteViewModel(store: store, entryUsecase: entryUsecase)

        // Pre-delete, API completion will trigger another sync
        syncUseCase.syncChildrenAfterDelete(parentUri: nil, uris: uris)

        await vm.deleteEntries(entries: entries) { deletedUris in
            // Synced again by EntryUseCase after API completion
        }
    }

    func uploadFilesToGroup(parentUri: String, files: [URL]) async {
        let isCurrentGroup = group?.uri == parentUri

        for file in files {
            store.newBackgroundJob(
                name: "Uploading \(file.lastPathComponent)",
                job: { [self] in
                    do {
                        if try file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                            throw BizError.isGroup
                        }

                        let en = try await entryUsecase.UploadFile(
                            parentUri: parentUri,
                            file: file,
                            properties: nil,
                            tags: nil,
                            document: nil
                        )
                        print("upload new entry \(en.id)/\(en.name)")

                        if isCurrentGroup {
                            await MainActor.run {
                                addChildren(infos: [en])
                            }
                        }
                    } catch {
                        sentAlert("upload file \(file.lastPathComponent) failed \(error)")
                    }
                },
                complete: {
                    NotificationCenter.default.post(name: .reopenGroup, object: [parentUri])
                }
            )
        }
    }

    private func parentUri(of uri: String) -> String {
        let components = uri.split(separator: "/")
        guard components.count > 1 else { return "/" }
        let parentPath = components.dropLast().joined(separator: "/")
        return "/" + parentPath
    }

    // MARK: - Inspector Edit Methods

    func updateDocumentMetadata(uri: String, update: DocumentUpdate) async {
        do {
            try await documentUsecase.updateDocumentMetadata(uri: uri, update: update)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("update document metadata failed: \(error)")
        }
    }

    func addProperty(uri: String, key: String, value: String) async {
        do {
            let entry = selectedEntryDetail
            var properties = entry?.property?.properties ?? [:]
            properties[key] = value
            let tags = entry?.property?.tags
            try await documentUsecase.setProperties(uri: uri, tags: tags, properties: properties)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("add property failed: \(error)")
        }
    }

    func updateProperty(uri: String, key: String, value: String) async {
        do {
            let entry = selectedEntryDetail
            var properties = entry?.property?.properties ?? [:]
            properties[key] = value
            let tags = entry?.property?.tags
            try await documentUsecase.setProperties(uri: uri, tags: tags, properties: properties)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("update property failed: \(error)")
        }
    }

    func deleteProperty(uri: String, key: String) async {
        do {
            let entry = selectedEntryDetail
            var properties = entry?.property?.properties ?? [:]
            properties.removeValue(forKey: key)
            let tags = entry?.property?.tags
            try await documentUsecase.setProperties(uri: uri, tags: tags, properties: properties)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("delete property failed: \(error)")
        }
    }

    func updateTags(uri: String, tags: [String]) async {
        do {
            try await documentUsecase.updateTags(uri: uri, tags: tags)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("update tags failed: \(error)")
        }
    }

    private func refreshSelectedEntryDetail() async {
        guard let entry = selectedEntryDetail else { return }
        do {
            selectedEntryDetail = try await entryUsecase.getEntryDetails(uri: entry.uri)
        } catch {
            sentAlert("refresh entry detail failed: \(error)")
        }
    }

    // MARK: - Group Config Methods

    func refreshChildren() async {
        guard !currentGroupUri.isEmpty else { return }
        resetPagination()
        resetChildren()
        await loadNextPage()
    }

    func loadGroupConfig(uri: String) async {
        do {
            selectedGroupConfig = try await entryUsecase.getGroupConfig(uri: uri)
        } catch {
            sentAlert("load group config failed: \(error)")
            selectedGroupConfig = nil
        }
    }

    func updateGroupConfig(uri: String, rss: RSSConfig?, filter: FilterConfig?) async {
        do {
            selectedGroupConfig = try await entryUsecase.updateGroupConfig(uri: uri, rss: rss, filter: filter)
        } catch {
            sentAlert("update group config failed: \(error)")
        }
    }
}
