//
//  GroupCreateView.swift
//  basenana
//
//  Created by zww on 2024/6/4.
//

import SwiftUI
import FeedKit
import Domain


struct GroupCreateView: View {
    @State private var viewModel: CreateDeleteViewModel
    @Environment(\.stateStore) private var store

    @Binding private var showCreateGroup: Bool
    private let onCreated: ((EntryInfo) -> Void)?

    // Parent group selection
    @State private var availableParents: [(uri: String, name: String, indent: Int)] = []
    @State private var selectedParentUri: String = ""
    @State private var groupName: String = ""

    // Group type selection
    @State var groupType: GroupType

    // RSS EntryGroup
    @State private var siteName: String = ""
    @State private var siteURL: String = ""
    @State private var rssFeed: String = ""
    @State private var errorMsg: String = ""
    @State private var isFeedParsed: Bool = false
    @State private var articleCount: Int = 0

    init(
        parentUri: String,
        groupType: GroupType,
        viewModel: CreateDeleteViewModel,
        store: StateStore,
        showCreateGroup: Binding<Bool>,
        onCreated: ((EntryInfo) -> Void)? = nil
    ) {
        self.groupType = groupType
        self.viewModel = viewModel
        self._showCreateGroup = showCreateGroup
        self.onCreated = onCreated

        // Initialize selections
        self._selectedParentUri = State(initialValue: parentUri)
    }

    var canCreate: Bool {
        if groupName.isEmpty {
            return false
        }
        if groupType == .feed {
            return isFeedParsed
        }
        return true
    }

    func resetFeedState() {
        isFeedParsed = false
        siteName = ""
        siteURL = ""
        articleCount = 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create Group")
                .font(.title2)
                .fontWeight(.bold)

            // Parent picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Parent")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("", selection: $selectedParentUri) {
                    ForEach(availableParents, id: \.uri) { parent in
                        let indentText = String(repeating: "  ", count: parent.indent)
                        Text(indentText + parent.name)
                            .tag(parent.uri)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .textFieldStyle(.squareBorder)
            }

            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Group Name", text: $groupName)
                    .textFieldStyle(.squareBorder)
            }

            // Group type selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Type")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("", selection: $groupType) {
                    Text("Standard").tag(GroupType.standard)
                    Text("RSS Feed").tag(GroupType.feed)
                    Text("Dynamic").tag(GroupType.dynamic)
                }
                .pickerStyle(.segmented)
                .onChange(of: groupType) { _, newValue in
                    if newValue != .feed {
                        resetFeedState()
                    }
                }
            }

            // RSS fields
            if groupType == .feed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Feed URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        TextField("https://...", text: $rssFeed)
                            .textFieldStyle(.squareBorder)
                            .autocorrectionDisabled()
                            .textContentType(.URL)
                            .frame(maxWidth: .infinity)

                        Button("Parse") {
                            parseRssTitle()
                        }
                        .buttonStyle(.bordered)
                        .disabled(rssFeed.isEmpty)
                    }

                    if !siteName.isEmpty {
                        HStack {
                            Text("Site:")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Text(siteName)
                                .font(.caption)
                            Spacer()
                            Text("\(articleCount) articles")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }

            // Error message
            if !errorMsg.isEmpty {
                Text(errorMsg)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()

            // Action buttons
            HStack {
                Spacer()

                Button("Cancel") {
                    showCreateGroup = false
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button {
                    Task {
                        await viewModel.createGroup(
                            parentUri: selectedParentUri,
                            option: buildOption(),
                            onCreated: onCreated
                        )
                        showCreateGroup = false
                    }
                } label: {
                    Text("Create")
                }
                .keyboardShortcut(.return, modifiers: [])
                .buttonStyle(.borderedProminent)
                .disabled(!canCreate)
            }
        }
        .padding(30)
        .frame(width: 400)
        .task {
            // Load available parent groups from store
            availableParents = store?.getVisibleGroupsForParentSelection() ?? []

            // Set initial parent name display
            if selectedParentUri.isEmpty, let firstParent = availableParents.first {
                selectedParentUri = firstParent.uri
            }
        }
    }

    func buildOption() -> EntryCreate {
        var opt = EntryCreate(
            parentUri: selectedParentUri.isEmpty ? "/" : selectedParentUri,
            name: groupName,
            kind: "group"
        )

        if groupType == .feed {
            opt.RSS = RSSConfig(
                feed: rssFeed,
                siteName: siteName,
                siteURL: siteURL,
                fileType: .webarchive
            )
        }

        return opt
    }

    func parseRssTitle() {
        guard let validUrl = URL(string: rssFeed) else {
            errorMsg = "Invalid URL"
            return
        }

        errorMsg = "Loading..."

        let parser = FeedParser(URL: validUrl)
        parser.parseAsync(result: { [self] result in
            switch result {
            case .success(let feed):
                siteName = feed.rssFeed?.title ?? feed.atomFeed?.title ?? feed.jsonFeed?.title ?? ""
                siteURL = feed.rssFeed?.link ?? feed.atomFeed?.links?.first?.attributes?.href ?? feed.jsonFeed?.homePageURL ?? ""

                // Count articles
                if let items = feed.rssFeed?.items {
                    articleCount = items.count
                } else if let entries = feed.atomFeed?.entries {
                    articleCount = entries.count
                } else if let items = feed.jsonFeed?.items {
                    articleCount = items.count
                } else {
                    articleCount = 0
                }

                if groupName.isEmpty {
                    groupName = sanitizeFileName(siteName)
                }
                isFeedParsed = true
                errorMsg = ""
            case .failure(let err):
                errorMsg = "Invalid feed: \(err.errorDescription ?? "")"
                isFeedParsed = false
            }
        })
    }
}
