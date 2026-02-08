//
//  EntryUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

import os
import Foundation



public class EntryUseCase: EntryUseCaseProtocol {

    private var entryRepo: EntryRepositoryProtocol
    private var fileRepo: FileRepositoryProtocol
    private var store: StateStore
    private let syncUseCase: EntrySyncUseCaseProtocol

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: EntryUseCase.self)
        )

    public init(entryRepo: EntryRepositoryProtocol, fileRepo: FileRepositoryProtocol, syncUseCase: EntrySyncUseCaseProtocol, store: StateStore = .shared) {
        self.entryRepo = entryRepo
        self.fileRepo = fileRepo
        self.store = store
        self.syncUseCase = syncUseCase
    }

    public func getEntryDetails(uri: String) async throws -> any  EntryDetail {
        do {
            return try await entryRepo.GetEntryDetail(uri: uri)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func renameEntry(uri: String, newName: String) async throws -> EntryDetail {
        do {
            let newUri = parentUri(of: uri) + "/" + newName
            let opt = ChangeParentOption()
            try await entryRepo.ChangeParent(uri: uri, newEntryUri: newUri, option: opt)
            let newEntry = try await getEntryDetails(uri: newUri)

            // Sync cache
            syncUseCase.syncTreeAfterRename(uri: uri, newName: newName, newUri: newUri)

            if let detail = newEntry as? EntryDetail {
                syncUseCase.syncChildrenAfterRename(id: detail.id, newName: newName, newUri: newUri)
            }

            return newEntry
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    private func parentUri(of uri: String) -> String {
        let components = uri.split(separator: "/")
        guard components.count > 1 else { return "/" }
        let parentPath = components.dropLast().joined(separator: "/")
        return "/" + parentPath
    }

    public func deleteEntry(uri: String) async throws {
        let entryDetail = try await entryRepo.GetEntryDetail(uri: uri)
        if !entryDetail.isGroup{
            return try await entryRepo.DeleteEntries(uris: [uri])
        }

        let children = try await listChildren(uri: uri, page: nil, pageSize: nil, sort: nil, order: nil)
        for child in children {
            try await deleteEntry(uri: child.uri)
        }

        return try await entryRepo.DeleteEntries(uris: [uri])
    }

    public func deleteEntries(uris: [String]) async throws {
        for uri in uris {
            try await deleteEntry(uri: uri)
        }

        // Sync cache - recursively delete all child nodes
        syncUseCase.syncChildrenAfterDelete(parentUri: nil, uris: uris)
        syncUseCase.syncTreeAfterDelete(uris: uris)
    }

    public func getTreeRoot() async throws -> any  EntryGroup {
        do {
            return try await entryRepo.GroupTree()
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func listChildren(uri: String, page: Int?, pageSize: Int?, sort: String?, order: String?) async throws -> [any  EntryInfo] {
        do {
            return try await entryRepo.ListGroupChildren(parentUri: uri, page: page, pageSize: pageSize, sort: sort, order: order)
        } catch RepositoryError.canceled {
            return []
        }
    }

    public func changeParent(uris: [String], newParentUri: String, finisher: @escaping (EntryDetail, EntryDetail) -> Void) async throws {
        do {
            // Handle root level (empty string as parentUri)
            var parent: EntryDetail?
            if newParentUri.isEmpty {
                parent = nil
            } else {
                parent = try await getEntryDetails(uri: newParentUri)
                if !parent!.isGroup {
                    throw BizError.notGroup
                }
            }

            for uri in uris {
                let entry = try await getEntryDetails(uri: uri)
                let oldParentUri = parentUri(of: uri)
                let newEntryUri = newParentUri == "/" ? "/" + entry.name : newParentUri + "/" + entry.name
                try await entryRepo.ChangeParent(uri: uri, newEntryUri: newEntryUri, option: ChangeParentOption())

                // Sync cache
                if entry.isGroup {
                    syncUseCase.syncTreeAfterMove(uri: uri, newParentUri: newParentUri)
                }
                syncUseCase.syncChildrenAfterMove(uris: [uri], fromParent: oldParentUri, toParent: newParentUri)

                DispatchQueue.main.async {
                    finisher(entry, parent ?? entry) // Pass dummy parent for root level
                }
            }

        } catch RepositoryError.canceled {
            return
        }
    }

    public func createGroups(parentUri: String, option: EntryCreate) async throws -> EntryInfo {
        let entry = EntryCreate(
            parentUri: parentUri,
            name: option.name,
            kind: option.kind,
            RSS: option.RSS,
            properties: option.properties,
            tags: option.tags,
            document: option.document
        )
        do {
            let newEntry = try await entryRepo.CreateEntry(entry: entry)

            // Sync cache
            if let groupDetail = newEntry as? EntryDetail,
               let group = groupDetail.toGroup() {
                syncUseCase.syncTreeAfterCreate(parentUri: parentUri, group: group)
            }
            syncUseCase.syncChildrenAfterCreate(parentUri: parentUri, entry: newEntry)

            return newEntry
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func UploadFile(
        parentUri: String,
        file: URL,
        properties: [String: String]? = nil,
        tags: [String]? = nil,
        document: DocumentCreate? = nil
    ) async throws -> EntryInfo {
        let fileHandle = try FileHandle(forReadingFrom: file)
        defer {
            fileHandle.closeFile()
        }

        let option = EntryCreate(
            parentUri: parentUri,
            name: file.lastPathComponent,
            kind: "raw",
            properties: properties,
            tags: tags,
            document: document
        )
        let entry = try await entryRepo.CreateEntry(entry: option)
        Self.logger.info("create entry \(entry.id) for upload")

        try await fileRepo.UploadFile(entry: entry.id, fileHandle: fileHandle)

        // Sync cache
        syncUseCase.syncChildrenAfterCreate(parentUri: parentUri, entry: entry)

        return entry
    }

    public func DownloadFile(entry: Int64, dirPath: String) async throws -> String {
        throw UseCaseError.unimplement
    }
}
