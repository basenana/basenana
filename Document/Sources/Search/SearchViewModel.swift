//
//  File.swift
//  Document
//
//  Created by Weiwei on 2024/12/28.
//

import os
import SwiftUI
import Foundation
import Entities
import AppState
import UseCaseProtocol

@Observable
@MainActor
public class SearchViewModel {
    var usecase: DocumentUseCaseProtocol
    var store: StateStore
    var search: String = ""
    
    var documents: [DocumentSearchItem] = []

    var isLoading: Bool = false
    var page: Int = 1
    var pageSize: Int = 10
    var hasMore = true
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: SearchViewModel.self)
        )

    public init(store: StateStore, usecase: DocumentUseCaseProtocol) {
        self.store = store
        self.usecase = usecase
    }
    
    public func doSearch(search: String) async {
        self.search = search
    }
    
    var showImagePreview: Bool {
        return store.setting.appearance.imagePreview != "none"
    }
    
    var showTextPreview: Bool {
        return store.setting.appearance.contentPreview
    }

    func loadNextPage() async {
        let nextPage = await listNextPage()
        if self.isLoading {
            return
        }
        
        Self.logger.info("search docuemnts len \(nextPage.count)")
        self.isLoading = true
        for nextDoc in nextPage {
            documents.append(nextDoc)
        }
        self.isLoading = false
    }
    
    func listNextPage() async -> [DocumentSearchItem] {
        Self.logger.info("ready to list next page document, page=\(self.page)")
        var nextPageList: [DocumentSearchItem] = []
        do {
            let nextDocuments = try await usecase.searchDocuments(search: search, page: page, pageSize: pageSize)
            
            if nextDocuments.isEmpty || pageSize > nextDocuments.count {
                Self.logger.info("no more documents, page=\(self.page)")
                hasMore = false
            }
            
            for document in nextDocuments {
                nextPageList.append(DocumentSearchItem(info: document))
            }
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
            return []
        } catch {
            sentAlert("list document page failed: \(error)")
            return []
        }
        
        page += 1
        return nextPageList
    }
}
