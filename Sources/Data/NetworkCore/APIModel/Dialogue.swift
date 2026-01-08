//
//  MessageModel.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData
import Domain

public struct APIRoom: Room {
    public var id: Int64
    
    public var namespace: String
    
    public var oid: Int64
    
    public var title: String
    
    public var prompt: String
    
    public var createdAt: Date
    
    public var messages: [any RoomMessage]
    
    public init(id: Int64, namespace: String, oid: Int64, title: String, prompt: String, createdAt: Date, messages: [any RoomMessage]) {
        self.id = id
        self.namespace = namespace
        self.oid = oid
        self.title = title
        self.prompt = prompt
        self.createdAt = createdAt
        self.messages = messages
    }
}

public struct APIRoomMessage: RoomMessage {
    public var id: Int64
    
    public var namespace: String
    
    public var roomid: Int64
    
    public var sender: String
    
    public var message: String
    
    public var sendAt: Date
    
    public var createdAt: Date
    
    public init(id: Int64, namespace: String, roomid: Int64, sender: String, message: String, sendAt: Date, createdAt: Date) {
        self.id = id
        self.namespace = namespace
        self.roomid = roomid
        self.sender = sender
        self.message = message
        self.sendAt = sendAt
        self.createdAt = createdAt
    }
}

