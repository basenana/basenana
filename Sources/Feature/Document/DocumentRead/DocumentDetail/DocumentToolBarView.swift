//
//  DocumentToolBarView.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//

import Foundation
import SwiftUI
import Domain
import Styleguide


struct DocumentToolBarView: View {
    let document: EntryDetail
    @Binding var isUnread: Bool
    @Binding var isMarked: Bool

    var body: some View {
        Button(action: {
            isUnread.toggle()
            NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(uri: document.uri, isUnread: isUnread))
        }, label: {
            Image(systemName: isUnread ? "circle.inset.filled" : "circle")
                .foregroundColor(.UnreadColor)
        })
        Button(action: {
            isMarked.toggle()
            NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(uri: document.uri, isMarked: isMarked))
        }, label: {
            Image(systemName: isMarked ? "bookmark.fill": "bookmark")
                .foregroundColor(.MarkedColor)
        })

        if let urlString = document.documentURL, let url = URL(string: urlString) {
            Button(action: {
                openUrlInBrowser(url: url)
            }, label: {
                Image(systemName: "safari")
            })

            Button(action: {
                copyToClipBoard(content: url.absoluteString)
                sentAlert("Link Copied")
            }, label: {
                Image(systemName: "link")
            })
        }
    }
}
