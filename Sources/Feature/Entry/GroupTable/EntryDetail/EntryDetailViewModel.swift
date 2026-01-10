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
    var groupTree = GroupTree.shared

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

    func renameEntry(entry: EntryDetail, newName: String) async -> Bool {
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
            try await entryUsecase.renameEntry(uri: entry.uri, newName: validName)
            if entry.isGroup {
                let entryDetail = try await entryUsecase.getEntryDetails(uri: entry.uri)
                if let grp = groupTree.getGroup(uri: entry.uri){
                    groupTree.removeChildGroup(parentUri: grp.parentUri, childUri: entry.uri)
                    groupTree.addChildGroup(parentUri: grp.parentUri, child: entryDetail.toGroup()!, grandChildren: grp.children)
                }
            }

            NotificationCenter.default.post(name: .reopenGroup, object: [parentUri(of: entry.uri)])
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
