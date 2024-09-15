//
//  Inbox.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation


public struct QuickInbox {
    var sourceType: SourceType
    var fileType: FileType
    var filename: String
    
    // source is url
    var url: String
    
    // source is raw
    var data: Data
}

enum FileType {
    case Bookmark
    case Html
    case Webarchive
}

public enum SourceType {
    case Url
    case Raw
}
