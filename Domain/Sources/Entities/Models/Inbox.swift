//
//  Inbox.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation


public struct QuickInbox {
    public var sourceType: SourceType
    public var fileType: FileType
    public var filename: String
    
    // source is url
    public var url: String
    
    // source is raw
    public var data: Data? = nil
    
    public init(sourceType: SourceType, fileType: FileType, filename: String) {
        self.sourceType = sourceType
        self.fileType = fileType
        self.filename = filename
        self.url = ""
        self.data = nil
    }
}

public enum FileType {
    case Bookmark
    case Html
    case Webarchive
    
    public func option() -> String {
        switch self {
        case .Bookmark:
            return "bookmark"
        case .Html:
            return "html"
        case .Webarchive:
            return "webarchive"
        }
    }
}

public enum SourceType {
    case Url
    case Raw
}
