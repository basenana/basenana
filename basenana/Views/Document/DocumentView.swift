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
            .listStyle(.inset)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("In Group", selection: $readerViewModel.groupFilter) {
                        Text("Select").tag(Int64(0))
                        ForEach(readerViewModel.documentGroups, id: \.self) { group in
                            Text(group.name).tag(group.id)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .onChange(of: readerViewModel.groupFilter ) { old, new in
                if old != new {
                    Task {
                        do {
                            try await readerViewModel.reloadNextPageDocuments()
                        } catch {
                            sendAlert("filter docuemnt failed \(error)")
                        }
                    }
                }
            }
            .task {
                do {
                    readerViewModel = try await DocumentReaderViewModel.load(prespective: prespective)
                }catch (let cancellationError as CancellationError){
                    log.warning("load document first page failed \(cancellationError)")
                } catch {
                    sendAlert("load document first page failed \(error)")
                }
            }
    }
}
