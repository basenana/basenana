//
//  InboxPreviewView.swift
//  Inbox
//
//  Created by Hypo on 2024/10/14.
//

import WebKit
import SwiftUI
import Foundation
import Entities
import WebPage


public struct InboxPreviewView: View {
    @State var page: WebPage
    
    var webView: WKWebView? = nil
    
    init(page: WebPage) {
        self.page = page
        self.webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    }
    
    init(page: WebPage, webView: WKWebView) {
        self.page = page
        self.webView = webView
    }
    
    public var body: some View {
        ReadabilityView(page: page, webView: webView!)
    }
}

