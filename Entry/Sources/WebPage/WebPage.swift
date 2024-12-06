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


public func webarchiveBaseMainResource(url: URL, mainResource: String, temporaryFileURL: URL) throws {
    
    if FileManager.default.fileExists(atPath: temporaryFileURL.path()){
        try FileManager.default.removeItem(at: temporaryFileURL)
    }
    
    FileManager.default.createFile(atPath: temporaryFileURL.path, contents: nil)
    print("create temporary file path: \(temporaryFileURL.path)")
    let fh = try FileHandle(forWritingTo: temporaryFileURL)
    
    
    DispatchQueue.global(qos: .background).async {
        WebArchiver.archiveWithMainResource(url: url, htmlContent: mainResource){ result in
            defer {
                do { try fh.close() } catch { }
            }
            
            if !result.errors.isEmpty{
                print("save failed \(result.errors)")
                return
            }
            if let d = result.plistData {
                do {
                    try fh.write(contentsOf: d)
                } catch{
                    print("save failed \(error)")
                }
            }
        }
    }
    return
}

