//
//  HtmlParser.swift
//  basenana
//
//  Created by Hypo on 2024/5/2.
//

import Foundation
import SwiftSoup
import WebArchiver
import Reeeed

enum WebError: Error {
    case InvalidUrl(String)
    case BodyIsEmpty
    case InvalidPath
    case Unknown
}


func parseURLTitle(urlStr: String) throws -> String {
    guard let url = URL(string: urlStr) else {
        throw WebError.InvalidUrl(urlStr)
    }
    
    var htmlStr: String = ""
    let group = DispatchGroup()
    group.enter()
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            log.error("fetch url \(urlStr) error: \(error)")
        } else if let data = data {
            htmlStr = String(data: data, encoding: .utf8) ?? ""
        }
        group.leave()
    }
    task.resume()
    group.wait()
    
    if htmlStr == "" {
        return "unknown"
    }
    
    let doc: Document = try! SwiftSoup.parse(htmlStr)
    let titleStr = try doc.title()
    
    return titleStr
}

struct WebPage {
    var url: URL
    var title: String = ""
    var htmlContent: String = ""
}

func fetchWebPage(url urlString: String) throws -> WebPage {
    guard let url = URL(string: urlString) else {
        throw WebError.InvalidUrl(urlString)
    }
    
    var wp = WebPage(url: url)
    let group = DispatchGroup()
    group.enter()
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            log.error("fetch url \(urlString) error: \(error)")
        } else if let data = data {
            wp.htmlContent = String(data: data, encoding: .utf8) ?? ""
        }
        group.leave()
    }
    task.resume()
    group.wait()

    if wp.htmlContent == "" {
        throw WebError.BodyIsEmpty
    }
    
    let doc: Document = try! SwiftSoup.parse(wp.htmlContent)
    wp.title = try doc.title()

    return wp
}



func webarchiveBaseMainResource(url: URL, mainResource: String) -> Data?{
    var pData: Data?
    let group = DispatchGroup()
    group.enter()
    WebArchiver.archiveWithMainResource(url: url, htmlContent: mainResource){ result in
        pData = result.plistData
        group.leave()
    }
    group.wait()
    return pData
}

class ReadablePage {
    
    var url: URL
    var urlTitle: String = ""
    var htmlContent: String = ""
    
    init(url: URL) {
        self.url = url
    }
    
    func parse () async throws {
        let result = try await Reeeed.fetchAndExtractContent(fromURL: url)
        
        urlTitle = result.title!
        htmlContent = """
    <head>
    <title>\(result.metadata?.title ?? urlTitle)</title>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=yes'>
    <style type='text/css'>body, table { width: 95%; margin: 0 auto; background-color: #FFF; color:#333; font-family: arial, sans-serif; font-weight: 100; font-size: 12pt; margin:2em 2em 2em 2em; }
    p, li { line-height: 150%; }
    h1, h2, h3 { color: #333; }
    a { color: #3366cc; border-bottom: 1px dotted #3366cc; text-decoration: none; }
    a:hover { color: #2647a3; border-bottom-color: color: #66ccff; }
    img { max-width: 50%; height: auto; margin: 10px auto; }
    pre { overflow: auto; }
    blockquote { color: #888888; padding: 10px; }
    figure { width: 100%; margin: 0px; }
    figure figcaption { display: none; }
    iframe { height: auto; width: auto; max-width: 95%; max-height: 100%; }</style>
    <body>
    <div> <a href="\(url.absoluteString)" target="_blank">\(url.host() ?? url.absoluteString)</a> <h1>\(urlTitle)</h1> </div>
    \(result.extracted.content ?? result.styledHTML)
    </body>
    """
    }
}

