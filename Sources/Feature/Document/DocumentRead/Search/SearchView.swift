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
            LazyVStack(spacing: 0) {
                if viewModel.searchResults.isEmpty && !viewModel.isSearching && !viewModel.searchQuery.isEmpty {
                    emptyStateView
                } else if viewModel.searchResults.isEmpty && viewModel.searchQuery.isEmpty {
                    promptView
                } else {
                    ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, item in
                        SearchResultCardView(item: item)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .onAppear {
                                if item.id == viewModel.searchResults.last?.id {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }

                        if index < viewModel.searchResults.count - 1 {
                            Divider()
                                .padding(.leading, 16)
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
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                let title = item.highlightTitle.isEmpty ? item.title : item.highlightTitle
                highlightedTitle(title)
                    .font(.title2)
                    .foregroundColor(.primary)

                Spacer()

                Text(item.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !item.highlightContent.isEmpty {
                highlightedContent(item.highlightContent)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if !item.content.isEmpty {
                Text(item.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHovered ? Color.secondary.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            gotoDestination(.readDocument(uri: item.uri))
        }
    }

    @ViewBuilder
    private func highlightedTitle(_ content: String) -> some View {
        let components = parseHTML(content)
        components.reduce(Text("")) { (result, component) in
            result + (component.isHighlight ? Text(component.text).bold() : Text(component.text))
        }
    }

    @ViewBuilder
    private func highlightedContent(_ content: String) -> some View {
        let components = parseHTML(content)
        components.reduce(Text("")) { (result, component) in
            result + (component.isHighlight ? Text(component.text).bold() : Text(component.text))
        }
    }

    struct TextComponent {
        let text: String
        let isHighlight: Bool
    }

    func parseHTML(_ html: String) -> [TextComponent] {
        var components: [TextComponent] = []
        var currentIndex = html.startIndex

        while let startRange = html.range(of: "<mark>", range: currentIndex..<html.endIndex),
              let endRange = html.range(of: "</mark>", range: startRange.upperBound..<html.endIndex) {
            if currentIndex < startRange.lowerBound {
                let normalText = String(html[currentIndex..<startRange.lowerBound])
                components.append(TextComponent(text: normalText, isHighlight: false))
            }

            let highlightText = String(html[startRange.upperBound..<endRange.lowerBound])
            components.append(TextComponent(text: highlightText, isHighlight: true))

            currentIndex = endRange.upperBound
        }

        if currentIndex < html.endIndex {
            let normalText = String(html[currentIndex..<html.endIndex])
            components.append(TextComponent(text: normalText, isHighlight: false))
        }

        return components
    }
}
