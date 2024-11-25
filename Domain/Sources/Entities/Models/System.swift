//
//  Notification.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation


public protocol NotificationMessage {
    var id: String { get }
    var title: String { get }
    var message: String { get }
    var type: String { get }
    var source: String { get }
    var action: String { get }
    var status: String { get }
    var time: Date { get }
}


public class BackgroundJob: Identifiable {
    public var id: String
    public var name: String
    public var startAt: Date
    
    public init(name: String, startAt: Date) {
        self.id = "\(RFC3339Formatter().string(from: Date()))-\(randomString(randomOfLength: 10))"
        self.name = name
        self.startAt = startAt
    }
}
