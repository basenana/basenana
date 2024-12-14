//
//  Store.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI
import Entities

@Observable
public class StateStore {
    public static var shared = StateStore()

    public var notifications = [String]()
    public var backgroupJobs = [BackgroundJob]()
    public var fsInfo = FSInfo()
    public var setting = Setting.global
    
    private init(){ }
}


public class FSInfo {
    public var fsApiReady = false
    public var namespace = ""
    public var rootID: Int64 = 0
    public var inboxID: Int64 = 0
    
    init(){}
    
    public init(namespace: String, rootID: Int64, inboxID: Int64) {
        self.fsApiReady = true
        self.namespace = namespace
        self.rootID = rootID
        self.inboxID = inboxID
    }
}
