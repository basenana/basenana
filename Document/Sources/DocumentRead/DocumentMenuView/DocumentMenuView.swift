//
//  DocumentMenuView.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import SwiftUI
import Foundation

struct DocumentMenuView: View {
    
    var body: some View {
        VStack {
            Section{
                Button("Go To Group", action: {
                })
            }
            
            Section{
                Button("Launch URL", action: {
                })
                Button("Copy URL", action: {
                })
            }
            
//            Section{
//                Menu("Mark To"){
//                    DocumentMarkMenuView(doc: $doc, readerViewModel: $readerViewModel)
//                }
//            }
        }
    }
}
    

struct DocumentMarkMenuView: View {
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
//                var isRead = readerViewModel.readed.contains(doc.id)
//                isRead.toggle()
//                store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, unread: !isRead)))
//                if isRead {
//                    readerViewModel.readed.insert(doc.id)
//                }else{
//                    readerViewModel.readed.remove(doc.id)
//                }
            }
        } label: {
//            Image(systemName: readerViewModel.readed.contains(doc.id) ? "circle.slash" : "circle.fill")
//                .resizable()
//                .frame(width: 5, height: 5)
//            Text(readerViewModel.readed.contains(doc.id) ? "Unread" : "Read")
        }
        Button {
            withAnimation(.easeInOut) {
//                var isMark = readerViewModel.marked.contains(doc.id)
//                isMark.toggle()
//                store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, marked: isMark)))
//                if isMark {
//                    readerViewModel.marked.insert(doc.id)
//                }else{
//                    readerViewModel.marked.remove(doc.id)
//                }
            }
        } label: {
//            Image(systemName: readerViewModel.marked.contains(doc.id) ? "bookmark.slash": "bookmark.fill")
//                .resizable()
//                .frame(width: 5, height: 5)
//            Text(readerViewModel.marked.contains(doc.id) ? "Unmark": "Mark")
        }
    }
}
