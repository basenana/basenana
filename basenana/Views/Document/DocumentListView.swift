//
//  DocumentListView.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import SwiftUI
import Foundation


struct DocumentListView: View {
    @Binding var readerViewModel: DocumentReaderViewModel
    @State private var appConfig = AppConfiguration.share
    
    @Environment(Store.self) private var store: Store
    @Environment(\.sendAlert) var sendAlert
    
    
    var body: some View {
        NavigationSplitView() {
            VStack {
                List(readerViewModel.documents, id:\.self, selection: $readerViewModel.selection) { document in
                    NavigationLink(value: document) {
                        DocumentItemView(doc: document, markReaded: readerViewModel.isMarkDocumentsReaded(doc: document)).id(document).tag(document as DocumentInfoModel?)
                            .onAppear { handleDocuementOnAppear(doc: document) }
                            .onDisappear { handleDocuementOnDisappear(doc: document) }
                    }.task{
                        do {
                            try await readerViewModel.checkAndLoadNextPage(document)
                        } catch {
                            sendAlert("load next page failed: \(error)")
                        }
                    }
                }
                if readerViewModel.isLoading {
                    Divider()
                    Text("Loading ...").padding(.vertical)
                }
            }.toolbar(removing: .sidebarToggle)
        } detail: {
            if let selected = readerViewModel.selection {
                DocumentDetailView(document: selected).id(selected)
            }
        }
        .onChange(of: readerViewModel.selection) { _, selectedDoc in
            if let doc = selectedDoc{
                if doc.unread {
                    store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, unread: false)))
                    readerViewModel.readed.insert(doc.id)
                }
            }
        }
        .contextMenu {
            if let selected = readerViewModel.selection {
                DocumentMenuView(doc: selected, readerViewModel: $readerViewModel).id(selected)
            }
        }
    }
    
    func handleDocuementOnAppear(doc: DocumentInfoModel) {
        if appConfig.autoRead {
            readerViewModel.needAutoReadDocument.insert(doc.id)
        }
    }
    
    func handleDocuementOnDisappear(doc: DocumentInfoModel) {
        if readerViewModel.needAutoReadDocument.contains(doc.id) && !readerViewModel.readed.contains(doc.id) {
            Task { @MainActor in
                store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, unread: false)))
                readerViewModel.readed.insert(doc.id)
            }
        }
    }
}

