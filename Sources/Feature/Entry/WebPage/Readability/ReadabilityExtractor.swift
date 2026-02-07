//
//  ReadabilityExtractor.swift
//  Feature
//
//  Extract readable content from HTML using SwiftSoup.
//

import Foundation
import SwiftSoup

public struct ReadabilityResult {
    public let title: String
    public let byline: String?
    public let content: String
    public let textContent: String
}

public final class ReadabilityExtractor {

    private static let unlikelyRoles = ["menu", "nav", "sidebar", "aside", "footer", "header", " advertisement", "comment", "portal", "related"]
    private static let unlikelyClasses = ["menu", "nav", "sidebar", "aside", "footer", "header", "comment", "ad", "social", "share", "related", "pager", "paginate"]
    private static let positiveClasses = ["article", "post", "entry", "content", "main", "text", "story", "body"]
    private static let negativeClasses = ["comment", "chat", "dialog", "modal", "popup", "tooltip", "sidebar", "menu", "ad", "banner"]

    public init() {}

    public func parse(html: String, url: String) throws -> ReadabilityResult {
        let doc = try SwiftSoup.parse(html, url)

        // Extract title
        let title = try extractTitle(doc)

        // Extract byline
        let byline = try extractByline(doc)

        // Remove unwanted elements
        try removeUnwantedElements(doc)

        // Find the main content
        let contentElement = try findMainContent(doc)

        // Clean the content
        try cleanContent(contentElement)

        let content = try contentElement.html()
        let textContent = try contentElement.text()

        return ReadabilityResult(
            title: title,
            byline: byline,
            content: wrapContent(title: title, byline: byline, url: url, content: content),
            textContent: textContent
        )
    }

    private func extractTitle(_ doc: Document) throws -> String {
        // Try og:title first
        if let ogTitle = try doc.select("meta[property=og:title]").first(),
           let title = try ogTitle.attr("content").nilIfEmpty() {
            return title
        }

        // Try title tag
        let title = try doc.title().nilIfEmpty() ?? ""

        // If title is empty or too long, try to clean it
        if title.isEmpty {
            return ""
        }

        // Clean common title patterns like "Site Name | Article Title"
        if let range = title.range(of: " \\| ") {
            return String(title[..<range.lowerBound])
        }
        if let range = title.range(of: " - ") {
            return String(title[..<range.lowerBound])
        }
        if let range = title.range(of: " :: ") {
            return String(title[..<range.lowerBound])
        }

        return title
    }

    private func extractByline(_ doc: Document) throws -> String? {
        // Try meta author
        if let metaAuthor = try? doc.select("meta[name=author]").first(),
           let author = try? metaAuthor.attr("content").nilIfEmpty() {
            return author
        }

        // Try meta article:author
        if let metaAuthor = try? doc.select("meta[property=article:author]").first(),
           let author = try? metaAuthor.attr("content").nilIfEmpty() {
            return author
        }

        // Look for byline elements
        if let byline = try? doc.select("[rel=author]").first(),
           let text = try? byline.text().nilIfEmpty() {
            return text
        }

        if let byline = try? doc.select(".author, .byline, [class*=author]").first(),
           let text = try? byline.text().nilIfEmpty() {
            return text
        }

        return nil
    }

    private func removeUnwantedElements(_ doc: Document) throws {
        // Remove scripts, styles, noscript, etc.
        let unwantedTags = ["script", "style", "noscript", "iframe", "object", "embed", "form", "nav", "aside", "footer", "header"]
        for tag in unwantedTags {
            try doc.select(tag).remove()
        }

        // Remove comments
        let body = try doc.body()
        if let body = body {
            removeComments(from: body)
        }
    }

    private func removeComments(from element: Element) {
        var toRemove: [Node] = []
        for node in element.getChildNodes() {
            if let commentNode = node as? Comment {
                toRemove.append(commentNode)
            } else if let element = node as? Element {
                removeComments(from: element)
            }
        }
        for node in toRemove {
            try? node.remove()
        }
    }

    private func findMainContent(_ doc: Document) throws -> Element {
        // Try common article selectors
        let articleSelectors = [
            "article",
            "[role=article]",
            ".post-content",
            ".article-content",
            ".entry-content",
            ".post",
            ".article",
            ".entry",
            "#main-content",
            "#content",
            ".content",
            "main"
        ]

        for selector in articleSelectors {
            if let element = try doc.select(selector).first(),
               try element.text().count > 100 {
                return element
            }
        }

        // Fallback to body
        return try doc.body() ?? doc
    }

    private func cleanContent(_ element: Element) throws {
        // Remove empty elements
        try element.select("p, div, span, a").forEach { el in
            let text = try el.text()
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let hasMedia = try !el.select("img, video, audio, iframe").isEmpty()
                if !hasMedia {
                    try el.remove()
                }
            }
        }

        // Remove hidden elements
        try element.select("[style*=display:none], [style*=display: none], [hidden]").remove()

        // Remove ads
        try element.select(".ad, .ads, [class*=ad-], [id*=ad-]").remove()

        // Remove links that are only URLs
        try element.select("a").forEach { link in
            let href = try? link.attr("href").nilIfEmpty()
            let text = try link.text().nilIfEmpty()
            if href == text || (href != nil && text?.hasPrefix("http") == true && text?.count ?? 0 < 100) {
                try link.replaceWith(TextNode(text ?? "", ""))
            }
        }
    }

    private func wrapContent(title: String, byline: String?, url: String, content: String) -> String {
        var html = "<html><head><meta charset='UTF-8'><title>\(escapeHTML(title))</title></head><body>"
        html += "<div><a href='\(escapeHTML(url))' target='_blank'>\(escapeHTML(URL(string: url)?.host ?? url))</a></div>"
        html += "<h1>\(escapeHTML(title))</h1>"

        if let byline = byline, !byline.isEmpty {
            html += "<p class='byline'>By \(escapeHTML(byline))</p>"
        }

        html += content
        html += "</body></html>"
        return html
    }

    private func escapeHTML(_ string: String) -> String {
        var result = string
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&#39;")
        return result
    }
}

private extension String {
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
}
