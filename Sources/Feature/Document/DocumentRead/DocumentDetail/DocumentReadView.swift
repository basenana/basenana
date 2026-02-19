//
//  DocumentReadView.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//

import SwiftUI
import Domain


public struct DocumentReadView: View {
    @State var document: EntryDetail? = nil
    @State var viewModel: DocumentReadViewModel
    @State var isUnread: Bool = false
    @State var isMarked: Bool = false

    @State private var isFridayChatVisible: Bool = false
    @StateObject private var chatViewModel: FridayChatViewModel

    public init(viewModel: DocumentReadViewModel) {
        self.viewModel = viewModel
        self._chatViewModel = StateObject(wrappedValue: FridayChatViewModel(fridayUseCase: viewModel.fridayUseCase))
    }

    public var body: some View {
        HSplitView {
            documentContentView

            if isFridayChatVisible {
                FridayChatView(viewModel: chatViewModel)
                    .frame(minWidth: 400, idealWidth: 400, maxWidth: 500)
            }
        }
        .onAppear {
            StateStore.shared.selectedEntryUri = viewModel.uri
        }
        .onDisappear {
            if StateStore.shared.selectedEntryUri == viewModel.uri {
                StateStore.shared.selectedEntryUri = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateDocumentMark)) { [self] notification in
            if let update = notification.object as? UpdateDocumentMark {
                if update.uri != viewModel.uri { return }
                if update.updateRead {
                    isUnread = update.isUnread
                    Task {
                        await viewModel.setDocumentReadStatus(isUnread: update.isUnread)
                    }
                }
                if update.updateMark {
                    isMarked = update.isMarked
                    Task {
                        await viewModel.setDocumentMarkStatus(isMarked: update.isMarked)
                    }
                }
            }
        }
        .navigationTitle(document?.documentTitle ?? document?.name ?? "")
        .frame(minWidth: 200, minHeight: 100)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if let doc = viewModel.entry {
                    DocumentToolBarView(
                        document: doc,
                        isUnread: $isUnread,
                        isMarked: $isMarked
                    )
                }
                Toggle(isOn: $isFridayChatVisible) {
                    Image(systemName: "sparkles")
                }
            }
        }
        .task {
            await viewModel.loadDocument()
            if let entry = viewModel.entry {
                self.document = entry
                isUnread = entry.documentUnread
                isMarked = entry.documentMarked
            }
        }
    }

    private var documentContentView: some View {
        Group {
            if viewModel.isLoading {
                Text("downloading...")
                    .font(.title)
                    .fontWeight(.thin)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let fileURL = viewModel.cachedFileURL {
                switch viewModel.fileType {
                case .pdf:
                    PDFDocumentView(fileURL: fileURL)
                case .html:
                    HTMLStringView(fileURL: fileURL, originalUrl: viewModel.entry?.documentURL.flatMap { URL(string: $0) })
                case .markdown:
                    MarkdownDocumentView(fileURL: fileURL)
                }
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                EmptyView()
            }
        }
    }
}
