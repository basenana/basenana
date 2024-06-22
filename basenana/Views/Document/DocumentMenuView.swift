//
//  DocumentMenuView.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import SwiftUI
import Foundation


struct DocumentMenuView: View {
    @State var doc: DocumentInfoModel
    @Binding var readerViewModel: DocumentReaderViewModel
    @Environment(Store.self) private var store: Store
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                var isRead = readerViewModel.readed.contains(doc.id)
                isRead.toggle()
                store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, unread: !isRead)))
                if isRead {
                    readerViewModel.readed.insert(doc.id)
                }else{
                    readerViewModel.readed.remove(doc.id)
                }
            }
        } label: {
            if readerViewModel.readed.contains(doc.id) {
                Image(systemName: "circle.fill").resizable().frame(width: 1, height: 1)
                Text("Unread")
            }else{
                Image(systemName: "circle").resizable().frame(width: 1, height: 1)
                Text("Read")
            }
        }
        Button {
            withAnimation(.easeInOut) {
                var isMark = readerViewModel.marked.contains(doc.id)
                isMark.toggle()
                store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, marked: isMark)))
                if isMark {
                    readerViewModel.marked.insert(doc.id)
                }else{
                    readerViewModel.marked.remove(doc.id)
                }
            }
        } label: {
            if readerViewModel.marked.contains(doc.id) {
                Image(systemName: "star").resizable().frame(width: 1, height: 1)
                Text("Unmark")
            }else{
                Image(systemName: "star.fill").resizable().frame(width: 1, height: 1)
                Text("Mark")
            }
        }
    }
}
