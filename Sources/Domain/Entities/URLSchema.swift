//
//  URLSchema.swift
//  Domain
//
//  Created by Hypo on 2024/11/24.
//
import Foundation


public func EntryUri(uri: String) -> URL{
    return URL(string: "basenana://entries\(uri)")!
}


public func parseUriFromURL(url: URL) -> String? {
    let path = url.path
    if path.isEmpty {
        return nil
    }
    return path
}


public enum EntryURI {
    public static let root = "/"
    public static let inbox = "/.inbox"
}
