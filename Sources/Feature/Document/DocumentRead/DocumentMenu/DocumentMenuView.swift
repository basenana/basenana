//
//  DocumentMenuView.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import SwiftUI
import Foundation
import Domain
import Styleguide

struct DocumentMenuView: View {
    private var section: String = ""
    @Binding var document: DocumentItem
    @State var parentURI: String
    @State var viewModel: DocumentListViewModel

    init(section: String, document: Binding<DocumentItem>, parentURI: String, viewModel: DocumentListViewModel) {
        self.section = section
        self._document = document
        self.parentURI = parentURI
        self.viewModel = viewModel
    }


    var body: some View {
        VStack {

            if let urlStr = document.info.documentURL, let u = parseUrlString(urlStr: urlStr) {
                Section(){
                    Button("Launch URL", action: {
                        Task {
                            if document.isUnread {
                                document.isUnread.toggle()
                                NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(uri: document.uri, isUnread: false))
                            }
                        }
                        openUrlInBrowser(url: u)
                    })
                    Button("Copy URL", action: {
                        copyToClipBoard(content: "\(u)")
                    })
                }
            }

            Section{
                Button("Go To EntryGroup", action: { gotoDestination(.groupList(groupUri: parentURI)) })
            }

            Section{
                Menu("Mark To"){
                    DocumentMarkMenuView(section: section, document: $document, viewModel: viewModel)
                }
            }
        }
    }
}


struct DocumentMarkMenuView: View {
    private var section: String
    @Binding var document: DocumentItem
    @State var viewModel: DocumentListViewModel

    init(section: String, document: Binding<DocumentItem>, viewModel: DocumentListViewModel) {
        self.section = section
        self._document = document
        self.viewModel = viewModel
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                document.isUnread.toggle()
                NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(uri: document.uri, isUnread: document.isUnread))
            }
        } label: {
            Image(systemName: document.isUnread ? "circle" : "circle.inset.filled")
                .resizable()
                .frame(width: 5, height: 5)
            Text(document.isUnread ? "Read" : "Unread")
        }
        Button {
            withAnimation(.easeInOut) {
                document.isMarked.toggle()
                NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(uri: document.uri, isMarked: document.isMarked))
            }
        } label: {
            Image(systemName: document.isMarked ? "bookmark": "bookmark.fill")
                .resizable()
                .frame(width: 5, height: 5)
            Text(document.isMarked ? "Unmark": "Mark")
        }
    }
}
