//
//  PDFDocumentView.swift
//  Document
//
//  Created by Hypo on 2025/01/10.
//

import SwiftUI
import PDFKit

#if os(macOS)
struct PDFDocumentView: NSViewRepresentable {
    let fileURL: URL

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        if let document = PDFDocument(url: fileURL) {
            nsView.document = document
        }
    }
}
#endif
