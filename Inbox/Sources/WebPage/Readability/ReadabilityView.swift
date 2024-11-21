//
//  SwiftReadability
//
//  Created by Chloe on 2016-06-20.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit


public class Readability {
    let webView: WKWebView
    var hasRenderedReadabilityHTML = false
    
    init(){
        webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        webView.configuration.suppressesIncrementalRendering = true
        addReadabilityUserScript()
    }
    
    public func getWebView() -> WKWebView {
        return self.webView
    }
    
    private func addReadabilityUserScript() {
        let script = ReadabilityUserScript()
        webView.configuration.userContentController.addUserScript(script)
    }
    
    private func renderHTML(readabilityContent: String) -> String {
        return htmlTemplate.replacingOccurrences(of: "{Content}", with: readabilityContent)
    }
    
    
    public func initializeReadability() {
        let readabilityInitializationJS: String
        do {
            readabilityInitializationJS = try loadReadabilityVenderFile(name: "readability_initialization", type: "js")
        } catch {
            fatalError("Couldn't load readability_initialization.js")
        }
        
        webView.evaluateJavaScript(readabilityInitializationJS) { [weak self] (result, error) in
            guard let result = result as? String else {
                return
            }
            guard let htmlContent = self?.renderHTML(readabilityContent: result) else {
                return
            }
            self?.webView.loadHTMLString(htmlContent, baseURL: nil)
        }
    }
}

class ReadabilityUserScript: WKUserScript {
    convenience override init() {
        let js: String
        do {
            js = try loadReadabilityVenderFile(name: "Readability", type: "js")
        } catch {
            fatalError("Couldn't load Readability.js \(error)")
        }
        
        self.init(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
}

func loadReadabilityVenderFile(name: String, type: String) throws -> String {
    let bundle = Bundle(for: Readability.self)
    guard let filePath = bundle.path(forResource: name, ofType: type) else {
        throw WebError.InvalidPath
    }
    
    return try String(contentsOfFile: filePath)
}



public struct ReadabilityView: NSViewRepresentable {
    public typealias NSViewType = WKWebView
    
    var page: WebPage
    var readability: Readability
    
    public init(page: WebPage) {
        self.page = page
        self.readability = Readability()
    }
    
    public func makeNSView(context: Context) -> WKWebView {
        let webView = self.readability.getWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        self.readability.hasRenderedReadabilityHTML = false
        nsView.loadHTMLString(page.htmlContent, baseURL: page.url)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(readability: self.readability)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        private let readability: Readability
        
        init(readability: Readability) {
            self.readability = readability
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
            if !self.readability.hasRenderedReadabilityHTML {
                self.readability.hasRenderedReadabilityHTML = true
                self.readability.initializeReadability()
            }
        }
    }
}


let htmlTemplate = """
<head>
<meta charset='UTF-8' />
<meta name='viewport' content='width=device-width, initial-scale=1, user-scalable=yes'>
<style type='text/css'>body, table { margin: 0 auto; background-color: #FFF; color:#333; font-family: arial, sans-serif; font-weight: 100; font-size: 12pt; margin:2em 2em 2em 2em; }
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
{Content}
</body>
"""
