//
//  MarkdownDocumentView.swift
//  Document
//
//  Created by Hypo on 2025/01/14.
//

import SwiftUI
import WebKit

#if os(macOS)
struct MarkdownDocumentView: NSViewRepresentable {
    let fileURL: URL

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        do {
            let markdown = try String(contentsOf: fileURL, encoding: .utf8)
            let base64 = Data(markdown.utf8).base64EncodedString(options: [])
            let html = generateHTML(base64: base64)
            nsView.loadHTMLString(html, baseURL: nil)
        } catch {
            nsView.loadHTMLString(errorHTML(error.localizedDescription), baseURL: nil)
        }
    }

    private func generateHTML(base64: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            font-size: 16px;
            line-height: 1.8;
            padding: 30px 50px;
            max-width: 800px;
            margin: 0 auto;
        }
        h1 { font-size: 2em; margin: 1.5em 0 0.5em; font-weight: 700; }
        h2 { font-size: 1.5em; margin: 1.5em 0 0.5em; font-weight: 600; }
        h3 { font-size: 1.25em; margin: 1.25em 0 0.5em; font-weight: 600; }
        h4, h5, h6 { font-size: 1em; margin: 1em 0 0.5em; font-weight: 600; }
        p { margin: 0 0 1.2em; }
        ul, ol { margin: 0 0 1em; padding-left: 1.8em; }
        li { margin: 0.4em 0; }
        blockquote {
            margin: 1em 0;
            padding: 0 1em;
            border-left: 4px solid #ddd;
            color: #666;
        }
        code {
            font-family: 'SF Mono', Menlo, Monaco, Consolas, monospace;
            font-size: 0.9em;
            background: rgba(0,0,0,0.06);
            padding: 0.15em 0.4em;
            border-radius: 4px;
        }
        pre {
            background: rgba(0,0,0,0.06);
            padding: 1.2em;
            border-radius: 8px;
            overflow-x: auto;
            margin: 1.2em 0;
            line-height: 1.6;
        }
        pre code {
            background: none;
            padding: 0;
            font-size: 0.85em;
        }
        img { max-width: 100%; height: auto; }
        a { color: #007AFF; text-decoration: none; }
        a:hover { text-decoration: underline; }
        hr { border: none; border-top: 1px solid #ddd; margin: 2em 0; }
        @media (prefers-color-scheme: light) {
            body { background-color: #FFFFFF; color: #1d1d1f; }
            code, pre { background: #f5f5f5; }
            blockquote { border-color: #ddd; color: #666; }
            hr { border-color: #ddd; }
        }
        @media (prefers-color-scheme: dark) {
            body { background-color: #1c1c1e; color: #f5f5f7; }
            code, pre { background: #2c2c2e; }
            blockquote { border-color: #3a3a3c; color: #98989d; }
            hr { border-color: #3a3a3c; }
        }
        </style>
        </head>
        <body>
        <div id="content"></div>
        <script>
        (function() {
            function parse(text) {
                var html = text
                    .replace(/^### (.*)$/gm, '<h3>$1</h3>')
                    .replace(/^## (.*)$/gm, '<h2>$1</h2>')
                    .replace(/^# (.*)$/gm, '<h1>$1</h1>')
                    .replace(/\\*\\*(.*?)\\*/g, '<strong>$1</strong>')
                    .replace(/_(.*?)_/g, '<strong>$1</strong>')
                    .replace(/\\*(.*?)\\*/g, '<em>$1</em>')
                    .replace(/_(.*?)_/g, '<em>$1</em>')
                    .replace(/`(.*?)`/g, '<code>$1</code>')
                    .replace(/```[\\s\\S]*?```/g, '<pre><code>$&</code></pre>')
                    .replace(/^> (.*)$/gm, '<blockquote>$1</blockquote>')
                    .replace(/^- (.*)$/gm, '<li>$1</li>')
                    .replace(/^(\\d+)\\. (.*)$/gm, '<li>$2</li>')
                    .replace(/\\[([^\\]]+)\\]\\(([^)]+)\\)/g, '<a href="$2">$1</a>')
                    .replace(/^---$/gm, '<hr>');
                return html;
            }

            try {
                var base64 = "\(base64)";
                var markdown = decodeURIComponent(escape(atob(base64)));
                var result = parse(markdown);
                document.getElementById('content').innerHTML = result;
            } catch(e) {
                document.body.innerHTML = '<pre style="color:red;">Error: ' + e.message + '</pre>';
            }
        })();
        </script>
        </body>
        </html>
        """
    }

    private func errorHTML(_ message: String) -> String {
        let escaped = message.replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        return """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"></head>
        <body style="color: red; font-family: sans-serif; padding: 20px;">\(escaped)</body>
        </html>
        """
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
