//
//  Notify.swift
//  Entry
//
//  Created by Hypo on 2024/12/6.
//

import Foundation


public extension Notification.Name {
    static let createGroup = Notification.Name(rawValue: "createGroup")
    static let createGroupInTree = Notification.Name(rawValue: "createGroupInTree")
    
    static let deleteEntry = Notification.Name(rawValue: "deleteEntry")
    static let deleteGroupInTree = Notification.Name(rawValue: "deleteGroupInTree")
    
    static let renameEntry = Notification.Name(rawValue: "renameEntry")
    static let renameGroupInTree = Notification.Name(rawValue: "renameGroupInTree")
    
    static let updateTree = Notification.Name(rawValue: "updateTree")
    static let reopenGroup = Notification.Name(rawValue: "reopenGroup")
}
