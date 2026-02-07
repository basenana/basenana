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

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: EntryUseCase.self)
        )

    public init(entryRepo: EntryRepositoryProtocol, fileRepo: FileRepositoryProtocol, store: StateStore = .shared) {
        self.entryRepo = entryRepo
        self.fileRepo = fileRepo
        self.store = store
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
            return try await getEntryDetails(uri: newUri)
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

        // 更新 Children 缓存
        store.removeChildren(uris: uris)

        // 更新 Tree 缓存 (如果是文件夹)
        for uri in uris {
            if let node = store.getTreeGroup(uri: uri) {
                store.removeTreeChildGroup(parentUri: node.parentUri, childUri: uri)
            }
        }
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
            let parent = try await getEntryDetails(uri: newParentUri)
            if !parent.isGroup {
                throw BizError.notGroup
            }

            for uri in uris {
                let entry = try await getEntryDetails(uri: uri)
                let newEntryUri = newParentUri + "/" + entry.name
                try await entryRepo.ChangeParent(uri: uri, newEntryUri: newEntryUri, option: ChangeParentOption())

                // 更新 Tree 缓存
                if entry.isGroup {
                    if let node = store.getTreeGroup(uri: uri) {
                        store.changeTreeParent(uri: uri, newParentUri: newParentUri)
                    }
                }

                DispatchQueue.main.async {
                    finisher(entry, parent)
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

            // 更新 Tree 缓存
            if let groupDetail = newEntry as? EntryDetail,
               let group = groupDetail.toGroup() {
                store.addTreeChildGroup(parentUri: parentUri, child: group, grandChildren: nil)
            }

            // 更新 Children 缓存 (如果当前在父目录下)
            if store.currentGroupUri == parentUri {
                let cached = CachedEntry(from: newEntry)
                store.appendChildren([cached])
            }

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

        // 更新 Children 缓存 (如果当前在父目录下)
        if store.currentGroupUri == parentUri {
            let cached = CachedEntry(from: entry)
            store.appendChildren([cached])
        }

        return entry
    }

    public func DownloadFile(entry: Int64, dirPath: String) async throws -> String {
        throw UseCaseError.unimplement
    }
}
