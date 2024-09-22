//
//  Store.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI

public class StateStore: Observable {
    public static var empty = StateStore()
    
    public var destinations = [Destination]()
    public var sidebarSelection: Destination = .mainContent
    public var alert = Alert()
    public var fsInfo = FSInfo()
    public var groupTree = GroupTree()
}


public class FSInfo {
    public var fsApiReady = false
    public var namespace = ""
    public var rootID: Int64 = 0
    public var inboxID: Int64 = 0
}


public class Alert {
    var alertMessage: String = ""
    var needAlert: Bool = false
}
