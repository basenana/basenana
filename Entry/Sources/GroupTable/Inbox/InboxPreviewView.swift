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
    @State var page: WebPageInfo

    var webView: WKWebView? = nil

    init(page: WebPageInfo) {
        self.page = page
        self.webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    }

    init(page: WebPageInfo, webView: WKWebView) {
        self.page = page
        self.webView = webView
    }
    
    public var body: some View {
        ReadabilityView(page: page, webView: webView!)
    }
}

