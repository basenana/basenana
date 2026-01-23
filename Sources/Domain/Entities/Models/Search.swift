//
//  Search.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation


public protocol Search {
    var query: String { get set }
}

public struct SearchResult {
    public var id: Int64
    public var uri: String
    public var title: String
    public var content: String
    public var highlightTitle: String
    public var highlightContent: String
    public var createdAt: Date
    public var changedAt: Date

    public init() {
        self.id = 0
        self.uri = ""
        self.title = ""
        self.content = ""
        self.highlightTitle = ""
        self.highlightContent = ""
        self.createdAt = Date()
        self.changedAt = Date()
    }

    public init(id: Int64, uri: String, title: String, content: String, highlightTitle: String, highlightContent: String, createdAt: Date, changedAt: Date) {
        self.id = id
        self.uri = uri
        self.title = title
        self.content = content
        self.highlightTitle = highlightTitle
        self.highlightContent = highlightContent
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}
