//
//  SearchViewModel.swift
//  Document
//
//  Created by Weiwei on 2024/12/28.
//

import os
import SwiftUI
import Foundation
import Domain

@Observable
@MainActor
public class SearchViewModel {
    var searchUseCase: any SearchUseCaseProtocol
    var store: StateStore
    var searchQuery: String = ""

    var searchResults: [SearchResultItem] = []

    var isSearching: Bool = false
    var isLoadingMore: Bool = false
    var page: Int = 1
    var pageSize: Int = 40
    var hasMore = true

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: SearchViewModel.self)
        )

    public init(store: StateStore, searchUseCase: any SearchUseCaseProtocol) {
        self.store = store
        self.searchUseCase = searchUseCase
    }

    public func doSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            searchQuery = ""
            return
        }

        searchQuery = query
        page = 1
        hasMore = true
        searchResults = []

        await loadNextPage()
    }

    public func loadNextPage() async {
        guard !isSearching && hasMore else { return }

        isSearching = true
        if page > 1 {
            isLoadingMore = true
        }

        Self.logger.info("searching: \(self.searchQuery), page=\(self.page)")

        do {
            let results = try await searchUseCase.Search(
                query: searchQuery,
                page: page,
                pageSize: pageSize
            )

            if results.isEmpty || pageSize > results.count {
                Self.logger.info("no more results, page=\(self.page)")
                hasMore = false
            } else {
                page += 1
            }

            let newItems = results.map { SearchResultItem(result: $0, searchQuery: searchQuery) }
            searchResults.append(contentsOf: newItems)
        } catch let error as UseCaseError where error == .canceled {
            Self.logger.info("search canceled")
        } catch {
            sentAlert("search failed: \(error)")
        }

        isSearching = false
        isLoadingMore = false
    }

    public func reset() {
        searchQuery = ""
        searchResults = []
        page = 1
        hasMore = true
        isSearching = false
        isLoadingMore = false
    }

    var showImagePreview: Bool {
        return store.setting.appearance.imagePreview != "none"
    }

    var showTextPreview: Bool {
        return store.setting.appearance.contentPreview
    }
}
