//
//  WebPage.swift
//  Inbox
//
//  Created by Hypo on 2024/05/02.
//


import Foundation
import SwiftSoup

public enum WebError: Error {
    case InvalidUrl(String)
    case BodyIsEmpty
    case InvalidPath
    case Unknown
}


public struct WebPage {
    public var url: URL
    public var title: String = ""
    public var htmlContent: String = ""
}


public func fetchWebPage(url urlString: String) throws -> WebPage {
    guard let url = URL(string: urlString) else {
        throw WebError.InvalidUrl(urlString)
    }
    
    var wp = WebPage(url: url)
    let group = DispatchGroup()
    group.enter()
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("fetch url \(urlString) error: \(error)")
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


func webarchiveBaseMainResource(url: URL, mainResource: String, fileHandle: FileHandle) throws {
    var err: Error? = nil
    let group = DispatchGroup()
    group.enter()
    WebArchiver.archiveWithMainResource(url: url, htmlContent: mainResource){ result in
        if !result.errors.isEmpty{
            err = result.errors.first
            return
        }
        if let d = result.plistData {
            do {
                try fileHandle.write(contentsOf: d)
            } catch{
                err = error
            }
        }
        group.leave()
    }
    group.wait()
    
    if let e = err {
        throw e
    }
    return
}

