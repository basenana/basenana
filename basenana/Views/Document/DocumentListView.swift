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
    
    @State var section = DocumentListSection()

    var body: some View {
        NavigationView() {
            VStack {
                List(readerViewModel.documents, id:\.self, selection: $readerViewModel.selection) { document in
                    DocumentListSectionView(sectionName: section.sectionNames[document.id])
                    NavigationLink(value: document) {
                        DocumentItemView(doc: document, markReaded: readerViewModel.isMarkDocumentsReaded(doc: document)).id(document).tag(document as DocumentInfoModel?)
                            .onAppear { handleDocuementOnAppear(doc: document) }
                            .onDisappear { handleDocuementOnDisappear(doc: document) }
                    }
                    .task {
                        section.updateSection(next: document)
                        do {
                            try await readerViewModel.checkAndLoadNextPage(document)
                        } catch {
                            sendAlert("load next page failed: \(error)")
                        }
                    }
                }
                if readerViewModel.isLoading {
                    Text("☁️Loading ...").padding(.vertical)
                }
            }
            .toolbar(removing: .sidebarToggle)
            .frame(minWidth: 300, idealWidth: 300)
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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}

struct DocumentListSectionView: View {
    var sectionName: String?
    
    var body: some View {
        if sectionName == nil || sectionName!.isEmpty {
            EmptyView()
        } else {
            Section(sectionName!){}
        }
    }
}


@Observable
class DocumentListSection {
    var sectionNames: [Int64: String] = [:]
    @ObservationIgnored private var lastSectionName: String = ""

    func updateSection(next: DocumentInfoModel) {
        if let _ = sectionNames[next.id]{
            return
        }
        let sk = dateFormatter.string(from: next.createdAt)
        if sk == lastSectionName {
            sectionNames[next.id] = ""
            return
        }
        lastSectionName = sk
        sectionNames[next.id] = sk
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}
