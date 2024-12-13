//
//  DocumentToolBarView.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//
import Foundation
import SwiftUI
import Entities
import AppState
import Styleguide


struct DocumentToolBarView: View {
    @State private var viewModel: DocumentReadViewModel
    @Binding var isUnread: Bool
    @Binding var isMarked: Bool
    
    public init(viewModel: DocumentReadViewModel, isUnread: Binding<Bool>, isMarked: Binding<Bool>) {
        self.viewModel = viewModel
        self._isUnread = isUnread
        self._isMarked = isMarked
    }
    
    var body: some View {
        Button(action: {
            isUnread.toggle()
            NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(doc: viewModel.docID, isUnread: isUnread))
        }, label: {
            Image(systemName: isUnread ? "circle.inset.filled" : "circle")
                .foregroundColor(.UnreadColor)
        })
        Button(action: {
            isMarked.toggle()
            NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(doc: viewModel.docID, isMarked: isMarked))
        }, label: {
            Image(systemName: isMarked ? "bookmark.fill": "bookmark")
                .foregroundColor(.MarkedColor)
        })
        
        // web file
        if let u = viewModel.targetURL {
            Button(action: {
                openUrlInBrowser(url: u)
            }, label: {
                Image(systemName: "safari")
            })
            
            Button(action: {
                copyToClipBoard(content: "\(u.absoluteString)")
                sentAlert("Link Copied")
            }, label: {
                Image(systemName: "link")
            })
        }
    }
}
