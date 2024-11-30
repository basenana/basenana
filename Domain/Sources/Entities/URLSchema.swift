//
//  URLSchema.swift
//  Domain
//
//  Created by Hypo on 2024/11/24.
//
import Foundation


public func EntryUrl(entryID: Int64) -> URL{
    return URL(string: "basenana://entries/\(entryID)")!
}


public func parseEntryIDFromURL(url: URL) -> Int64? {
    let pathParts = url.pathComponents
    if let mayBeID = pathParts.last {
        return Int64(mayBeID)
    }
    return nil
}
