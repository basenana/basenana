//
//  BaseViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/30.
//

import os
import SwiftUI
import Domain


@Observable
@MainActor
public class BaseViewModel {

    // tree store
    var groupTree = GroupTree.shared

    var store: StateStore
    var entryUsecase: any EntryUseCaseProtocol

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: "Entry")
        )

    init(store: StateStore, entryUsecase: any EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }

    func describeEntry(uri: String) async -> EntryDetail? {
        do {
            return try await entryUsecase.getEntryDetails(uri: uri)
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("describe entry failed: \(error)")
        }
        return nil
    }

    func getGroup(uri: String) async -> EntryGroup? {
        do {
            let groupEntry = try await entryUsecase.getEntryDetails(uri: uri)
            return groupEntry.toGroup()
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("get group failed: \(error)")
        }
        return nil
    }

    func moveEntriesToGroup(entryURLs: [URL], newParentUri: String) async -> Bool {
        var entryUris: [String] = []
        var files = [URL]()

        for url in entryURLs {
            switch url.scheme {
            case "basenana":

                let targetID = parseEntryIDFromURL(url: url)
                guard targetID != nil && targetID! > 0 else {
                    sentAlert("\(url) not a valid entry")
                    return false
                }
                entryUris.append("/\(targetID!)")

            case "file":

                files.append(url)

            default:

                Self.logger.notice("[moveEntriesAndUpdateTree] unknown url schema \(url)")
                return false
            }
        }

        if !entryUris.isEmpty {
            return await moveEntriesToGroup(entryUris: entryUris, newParentUri: newParentUri)
        }

        if !files.isEmpty {
            do {
                try await uploadFiles(parentUri: newParentUri, files: files)
            } catch {
                sentAlert("upload files failed \(error)")
                return false
            }
            return true
        }

        return false
    }

    func moveEntriesToGroup(entryUris: [String], newParentUri: String) async -> Bool {
        do {
            try await entryUsecase.changeParent(uris: entryUris, newParentUri: newParentUri) { target, parent in
                assert(Thread.isMainThread)
                if target.isGroup {
                    if let grp = GroupTree.shared.getGroup(uri: target.uri) {
                        GroupTree.shared.removeChildGroup(parentUri: "/\(target.parent)", childUri: target.uri)
                        GroupTree.shared.addChildGroup(parentUri: parent.uri, child: grp.group, grandChildren: grp.children)
                    }
                }
                NotificationCenter.default.post(name: .reopenGroup, object: [target.uri, parent.uri])
            }
        } catch {
            sentAlert("move entry failed \(error)")
            return false
        }

        return false
    }

    func replicateEntryToGroup(entryUris: [String], newParentUri: String) async {
        sentAlert("not support")
    }

    // MARK file upload/download
    func uploadFiles(parentUri: String, files: [URL]) async throws  {
        for file in files {
            store.newBackgroundJob(
                name: "Uploading \(file.lastPathComponent)",
                job: {
                    let properties: [String:String] = [Property.LocalFile:file.path()]
                    do {
                        if try file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                            throw BizError.isGroup
                        }

                        let en = try await self.entryUsecase.UploadFile(parent: 0, file: file, properties: properties)
                        Self.logger.notice("upload new entry \(en.id)/\(en.name)")
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
}
