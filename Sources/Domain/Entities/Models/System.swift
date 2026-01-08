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

