//
//  Search.swift
//  Document
//
//  Created by Hypo on 2024/12/11.
//
import SwiftUI
import Domain
import Styleguide

public struct SearchView: View {
    @State var searchQuery: String
    @State var viewModel: SearchViewModel

    public init(search: String, viewModel: SearchViewModel) {
        self.searchQuery = search
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            searchBar

            Divider()

            resultsList
        }
        .frame(minWidth: 300)
        .toolbar(removing: .sidebarToggle)
        .onAppear {
            if !searchQuery.isEmpty {
                Task {
                    await viewModel.doSearch(query: searchQuery)
                }
            }
        }
        .onDisappear {
            viewModel.reset()
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search documents...", text: $searchQuery)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.doSearch(query: searchQuery)
                    }
                }

            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                    viewModel.reset()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            if viewModel.isSearching && viewModel.searchResults.isEmpty {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(NSColor.textBackgroundColor))
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if viewModel.searchResults.isEmpty && !viewModel.isSearching && !viewModel.searchQuery.isEmpty {
                    emptyStateView
                } else if viewModel.searchResults.isEmpty && viewModel.searchQuery.isEmpty {
                    promptView
                } else {
                    ForEach(viewModel.searchResults) { item in
                        SearchResultCardView(item: item)
                            .onAppear {
                                if item.id == viewModel.searchResults.last?.id {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                    }

                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding()
                    } else if viewModel.hasMore && !viewModel.searchResults.isEmpty {
                        loadMoreButton
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No results found")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var promptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Search your documents")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Enter keywords to find documents")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var loadMoreButton: some View {
        Button(action: {
            Task {
                await viewModel.loadNextPage()
            }
        }) {
            Text("Load More")
                .font(.subheadline)
                .foregroundColor(.accentColor)
        }
        .padding()
    }
}

struct SearchResultCardView: View {
    let item: SearchResultItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        HighlightedTitle(title: item.title, key: item.searchQuery)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(item.dateString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(item.uri)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    if !item.content.isEmpty {
                        HighlightedText(content: item.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.CardBackground)
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            gotoDestination(.readDocument(uri: item.uri))
        }
    }
}
