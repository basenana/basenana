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
        self.htmlContent = """
<head>
<meta charset='UTF-8' />
<meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=yes'>
<style type='text/css'>body, table { width: 95%; margin: 0 auto; background-color: #FFF; color:#333; font-family: arial, sans-serif; font-weight: 100; font-size: 12pt; margin:2em 2em 2em 2em; }
body { padding-right: 20px; }
p, li { line-height: 150%; }
a { color: #3366cc; border-bottom: 1px dotted #3366cc; text-decoration: none; }
a:hover { color: #2647a3; border-bottom-color: color: #66ccff; }
img { max-width: 80%; height: auto; margin: 10px auto; display: block; }
pre {
    border: 1px solid #ddd;
    border-radius: 3px;
    padding: 10px;
    overflow-x: auto;
    white-space: pre-wrap;
    word-wrap: break-word;
    font-family: 'Courier New', monospace;
    line-height: 1.5;
}
blockquote { color: #888888; padding: 10px; }
figure { width: 100%; margin: 0px; }
figure figcaption { display: none; }
iframe { height: auto; width: auto; max-width: 95%; max-height: 100%; }
@media (prefers-color-scheme: light) {
    h1, h2, h3 { color: #333; }
    pre, code {
        background-color: #f6f8fa;
        color: #333;
    }
}
@media (prefers-color-scheme: dark) {
    h1, h2, h3 { color: #fff; }
    body {
        background-color: #333;
        color: #fff;
    }
    pre, code {
        background-color: #282a36;
        color: #f8f8f2;
    }
}
</style>
<body>
\(htmlContent)
</body>
"""
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
#endif
