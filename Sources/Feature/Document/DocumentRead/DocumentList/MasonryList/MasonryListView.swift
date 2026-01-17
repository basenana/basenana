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
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(viewModel.sectionDocuments) { section in
                        MasonrySectionView(section: section, viewModel: viewModel)
                            .padding(.horizontal, 20)
                    }

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
        .toolbar(removing: .sidebarToggle)
        .frame(minWidth: 300, idealWidth: 300)
        .navigationTitle(viewModel.prespective.Title)
    }
}

struct MasonryListReadAllView: View {
    @State var viewModel: DocumentListViewModel
    @State var hasUnread: Bool = false
    
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
                        await viewModel.setAllAppearedDocumentRead(before: 0, isAuto: false)
                        hasUnread = false
                    }
                }, label: {
                    Label("Make All as Read", systemImage: "checkmark.rectangle.stack")
                })
                .buttonStyle(.borderless)
                .padding(.vertical)
                Spacer()
            }
        }
        .task {
            for sectionDocument in viewModel.sectionDocuments.reversed() {
                for document in sectionDocument.documents {
                    if document.isUnread {
                        hasUnread = true
                    }
                }
            }
        }
    }
}
