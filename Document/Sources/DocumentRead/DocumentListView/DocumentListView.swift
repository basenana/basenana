//
//  DocumentListView.swift
//  Entry
//
//  Created by Hypo on 2024/11/16.
//

import SwiftUI
import Foundation
import AppState
import Entities


@available(macOS 14.0, *)
public struct DocumentListView: View {
    @State var viewModel: DocumentListViewModel
    @State var section = DocumentListSection()
    
    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            List(viewModel.mainDocuments) { document in
                if viewModel.prespective == .unread {
                    // group by document time
                    DocumentListSectionView(sectionName: section.sectionNames[document.id])
                }
                
                Button(action: {
                    viewModel.store.dispatch(.gotoDestination(.readDocument(document: document.id)))
                }){
                    DocumentItemView(doc: document, viewModel: viewModel)
                    .task {
                        section.updateSection(next: document)
                        viewModel.checkAndLoadNextPage(document)
                    }
                }
            }
            if viewModel.isLoading {
                Text("☁️Loading ...").padding(.vertical)
            }
        }
        .task {
            viewModel.initNextPage()
        }
        .toolbar(removing: .sidebarToggle)
        .frame(minWidth: 300, idealWidth: 300)
        .navigationTitle(viewModel.prespective.Title)
    }
}

@available(macOS 14.0, *)
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


@available(macOS 14.0, *)
@Observable
class DocumentListSection {
    var sectionNames: [Int64: String] = [:]
    @ObservationIgnored private var lastSectionName: String = ""

    func updateSection(next: DocumentItem) {
        if let _ = sectionNames[next.id]{
            return
        }
        let sk = buildSection(next: next)
        if sk == lastSectionName {
            sectionNames[next.id] = ""
            return
        }
        lastSectionName = sk
        sectionNames[next.id] = sk
    }
    
    func buildSection(next: DocumentItem) -> String {
        if Calendar.current.isDateInToday(next.info.createdAt){
            return "TODAY"
        }
        if Calendar.current.isDateInYesterday(next.info.createdAt){
            return "YESTERDAY"
        }

        return dateFormatter.string(from: next.info.createdAt)
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}


#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        DocumentListView(viewModel: DocumentListViewModel(prespective: .unread, store: StateStore.empty, usecase: MockDocumentUseCase()))
    }
}

#endif
