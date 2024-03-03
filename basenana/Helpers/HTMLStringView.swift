//
//  HTMLStringView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import SwiftUI
import WebKit

#if os(iOS)
struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#endif

#if os(macOS)
struct HTMLStringView: NSViewRepresentable {
    typealias NSViewType = WKWebView
    let htmlContent: String
    
    init(htmlContent: String) {
        self.htmlContent = htmlContent
    }
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#endif
