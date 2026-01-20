//
//  MasonryListView.swift
//  Document
//
//  Created by Hypo on 2024/12/4.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import Domain
import Domain


public struct MasonryListView: View {
    @State var viewModel: DocumentListViewModel
    @State private var loadingId: Int = 0

    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if viewModel.sectionDocuments.isEmpty && !viewModel.isLoading {
                VStack(spacing: 12) {
                    Image(systemName: "text.below.folder")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No documents.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical) {
                    ForEach(viewModel.sectionDocuments) { section in
                        MasonrySectionView(section: section, viewModel: viewModel)
                            .padding(.horizontal, 20)
                    }

                    LazyVStack{
                        if viewModel.hasMore {
                            ProgressView()
                                .padding(.vertical)
                                .id(loadingId)
                                .scaleEffect(0.8)
                                .frame(maxWidth: .infinity)
                                .onAppear {
                                    Task {
                                        await viewModel.loadNextPage()
                                        await viewModel.setAllAppearedDocumentRead()
                                        loadingId += 1
                                    }
                                }
                        } else {
                            MasonryListReadAllView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
        .toolbar(removing: .sidebarToggle)
        .frame(minWidth: 300, idealWidth: 300)
        .navigationTitle(viewModel.prespective.Title)
    }
}

struct MasonryListReadAllView: View {
    @State var viewModel: DocumentListViewModel

    var hasUnread: Bool {
        viewModel.sectionDocuments.contains { section in
            section.documents.contains { $0.isUnread }
        }
    }

    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Divider()
        HStack(alignment: .center){
            if hasUnread {
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.setAllDocumentRead()
                    }
                }, label: {
                    Label("Make All as Read", systemImage: "checkmark.rectangle.stack")
                })
                .buttonStyle(.borderless)
                .padding(.vertical)
                Spacer()
            }
        }
    }
}
