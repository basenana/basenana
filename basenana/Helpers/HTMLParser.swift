//
//  HtmlParser.swift
//  basenana
//
//  Created by Hypo on 2024/5/2.
//

import Foundation
import SwiftSoup
import WebArchiver


func parseURLTitle(urlStr: String) throws -> String {
    var htmlStr: String = ""
    let url = URL(string: urlStr)!
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
