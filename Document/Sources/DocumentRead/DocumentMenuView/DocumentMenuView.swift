//
//  DocumentMenuView.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import SwiftUI
import Foundation
import Entities

struct DocumentMenuView: View {
    private var section: String = ""
    @Binding var document: DocumentItem
    @State var entry: EntryDetail
    @State var viewModel: DocumentListViewModel
    
    init(section: String, document: Binding<DocumentItem>, entry: EntryDetail, viewModel: DocumentListViewModel) {
        self.section = section
        self._document = document
        self.entry = entry
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        VStack {
            
            if let u = parseUrlString(urlStr: getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL])?.value ?? "" ){
                Section(){
                    Button("Launch URL", action: {
                        Task {
                            if document.isUnread {
                                document.isUnread = false
                                await viewModel.setDocumentReadStatus(section: section, document: document.id, isUnread: false)
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
                Button("Go To Group", action: {
                    viewModel.store.dispatch(.gotoDestination(.groupList(group: entry.parent)))
                })
            }
            
            Section{
                Menu("Mark To"){
                    DocumentMarkMenuView(section: section, document: $document, viewModel: viewModel)
                }
            }
        }
    }
    
    func getEntryProperty(keys: [String]) -> EntryProperty?{
        for k in keys {
            for p in entry.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
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
                Task {
                    await viewModel.setDocumentReadStatus(section: section, document: document.id, isUnread: document.isUnread)
                }
            }
        } label: {
            Image(systemName: document.isUnread ? "circle.slash" : "circle.fill")
                .resizable()
                .frame(width: 5, height: 5)
            Text(document.isUnread ? "Read" : "Unread")
        }
        Button {
            withAnimation(.easeInOut) {
                document.isMarked.toggle()
                Task {
                    await viewModel.setDocumentMarkStatus(section: section, document: document.id, isMark: document.isMarked)
                }
            }
        } label: {
            Image(systemName: document.isMarked ? "bookmark.slash": "bookmark.fill")
                .resizable()
                .frame(width: 5, height: 5)
            Text(document.isMarked ? "Unmark": "Mark")
        }
    }
}
