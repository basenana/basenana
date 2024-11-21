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
    public var data: Data
}

public enum FileType {
    case Bookmark
    case Html
    case Webarchive
}

public enum SourceType {
    case Url
    case Raw
}
