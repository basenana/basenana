//
//  NotificationModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import Foundation
import Domain


public struct APINotification: NotificationMessage {
    public var id: String
    
    public var title: String
    
    public var message: String
    
    public var type: String
    
    public var source: String
    
    public var action: String
    
    public var status: String
    
    public var time: Date
    
    public init(id: String, title: String, message: String, type: String, source: String, action: String, status: String, time: Date) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.source = source
        self.action = action
        self.status = status
        self.time = time
    }
}
