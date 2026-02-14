//
//  CaptureData.swift
//  Feature
//
//  Data structure for capture requests from browser extension.
//

import Foundation

public struct CaptureData: Identifiable, Hashable, Codable {
    public let id: UUID
    public let url: String
    public let title: String
    public let content: String

    public init(url: String, title: String, content: String) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.content = content
    }
}
