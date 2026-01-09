//
//  DocumentReadViewModel.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//

import os
import SwiftUI
import Foundation
import Domain

@Observable
@MainActor
public class DocumentReadViewModel {
    var uri: String
    var store: StateStore
    var usecase: any DocumentUseCaseProtocol
    var entry: EntryDetail? = nil

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: DocumentReadViewModel.self)
        )

    public init(uri: String, store: StateStore, usecase: any DocumentUseCaseProtocol) {
        self.uri = uri
        self.store = store
        self.usecase = usecase
    }

    func loadDocument() async -> EntryDetail? {
        do {
            entry = try await usecase.getDocumentEntry(uri: uri)
            return entry
        } catch {
            sentAlert("load document failed: \(error)")
        }
        return nil
    }

    var targetURL: URL? {
        get {
            if let pro = getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL]) {
                if let u = URL(string: pro.value) {
                    return u
                }
            }
            return nil
        }
    }

    func getEntryProperty(keys: [String]) -> EntryProperty? {
        guard entry != nil else {
            return nil
        }
        for k in keys {
            for p in entry!.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}
