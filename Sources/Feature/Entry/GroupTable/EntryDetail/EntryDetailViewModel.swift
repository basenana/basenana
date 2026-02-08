//
//  EntryDetailViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//

import os
import SwiftUI
import Domain
import Domain
import Domain


@Observable
@MainActor
public class EntryDetailViewModel {
    var store: StateStore
    var entryUsecase: any EntryUseCaseProtocol

    var errorMessage: String = ""

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: EntryDetailViewModel.self)
        )

    public init(store: StateStore, entryUsecase: any EntryUseCaseProtocol) {
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

    func renameEntry(entry: EntryDetail, newName: String, onRenamed: ((Int64, String, String) -> Void)? = nil) async -> Bool {
        Self.logger.notice("rename entry \(entry.name) = > \(newName)")
        if entry.name == newName {
            return true
        }

        let validName = sanitizeFileName(newName)
        if validName != newName {
            errorMessage = "\(newName) is invalid"
            return false
        }

        do {
            let newDetail = try await entryUsecase.renameEntry(uri: entry.uri, newName: validName)

            if entry.isGroup {
                // Remove old node from Tree, add new node
                if let node = store.getTreeGroup(uri: entry.uri) {
                    store.removeTreeChildGroup(parentUri: node.parentUri, childUri: entry.uri)
                    if let group = newDetail.toGroup() {
                        store.addTreeChildGroup(parentUri: node.parentUri, child: group, grandChildren: node.children)
                    }
                }
            }

            onRenamed?(entry.id, validName, newDetail.uri)
            NotificationCenter.default.post(name: .reopenGroup, object: [parentUri(of: newDetail.uri)])
        } catch {
            errorMessage = "rename failed \(error)"
            return false
        }

        return true
    }

    private func parentUri(of uri: String) -> String {
        let components = uri.split(separator: "/")
        guard components.count > 1 else { return "/" }
        let parentPath = components.dropLast().joined(separator: "/")
        return "/" + parentPath
    }
}
