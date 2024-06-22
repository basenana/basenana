//
//  BaseDocumentView.swift
//  basenana
//
//  Created by zww on 2024/6/3.
//

import SwiftUI

struct DocumentView: View {
    var prespective : DocumentPrespective
    
    @State private var readerViewModel = DocumentReaderViewModel()
    @Environment(\.sendAlert) var sendAlert
    
    var body: some View {
        DocumentListView(readerViewModel: $readerViewModel)
            .frame(minWidth: 300, idealWidth: 300)
            .listStyle(.inset)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Picker("In Group", selection: $readerViewModel.groupFilter) {
                        Text("Select").tag(Int64(0))
                        ForEach(readerViewModel.documentGroups, id: \.self) { group in
                            Text(group.name).tag(group.id)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .onChange(of: readerViewModel.groupFilter ) { _, _ in
                log.info("reload next page \(readerViewModel.groupFilter)")
                Task { @MainActor in
                    do {
                        try await readerViewModel.reloadNextPageDocuments()
                    } catch {
                        sendAlert("\(error)")
                    }
                }
            }
            .task {
                do {
                    try await readerViewModel.initFirstPageDocuments(prespective: prespective)
                } catch {
                    sendAlert("\(error)")
                }
            }
    }
}
