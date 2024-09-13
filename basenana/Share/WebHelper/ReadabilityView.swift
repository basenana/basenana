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



struct ReadabilityView: NSViewRepresentable {
    typealias NSViewType = WKWebView
    
    var page: WebPage
    var readability: Readability
    
    init(page: WebPage) {
        self.page = page
        self.readability = Readability()
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = self.readability.getWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        self.readability.hasRenderedReadabilityHTML = false
        nsView.loadHTMLString(page.htmlContent, baseURL: page.url)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(readability: self.readability)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private let readability: Readability
        
        init(readability: Readability) {
            self.readability = readability
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
            if !self.readability.hasRenderedReadabilityHTML {
                self.readability.hasRenderedReadabilityHTML = true
                self.readability.initializeReadability()
            }
        }
    }
}
