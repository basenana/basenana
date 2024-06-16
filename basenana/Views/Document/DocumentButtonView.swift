//
//  DocumentButtonView.swift
//  basenana
//
//  Created by zww on 2024/6/4.
//

import SwiftUI

struct DocumentButtonView: View {
    var doc: DocumentInfoModel
    @Environment(AlertStore.self) var alert
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                do {
                    try service.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, unread: !doc.unread))
                } catch {
                    alert.trigger(message: "\(error)")
                }
            }
        } label: {
            if doc.unread {
                Image(systemName: "circle").resizable().frame(width: 1, height: 1)
                Text("Read")
            }else{
                Image(systemName: "circle.fill").resizable().frame(width: 1, height: 1)
                Text("Unread")
            }
        }
        Button {
            withAnimation(.easeInOut) {
                do {
                    try service.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, marked: !doc.marked))
                } catch {
                    alert.trigger(message: "\(error)")
                }
            }
        } label: {
            if doc.marked {
                Image(systemName: "star").resizable().frame(width: 1, height: 1)
                Text("Unmark")
            }else{
                Image(systemName: "star.fill").resizable().frame(width: 1, height: 1)
                Text("Mark")
            }
        }
    }
}
