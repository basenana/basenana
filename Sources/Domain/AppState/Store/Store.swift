//
//  Store.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI


@Observable
public class StateStore {
    public static var shared = StateStore()

    public var notifications = [String]()
    public var backgroupJobs = [BackgroundJob]()
    public var fsInfo = FSInfo()
    public var setting = Setting.global

    // Global panel visibility states
    public var showInspector: Bool = false
    public var showDocumentView: Bool = true

    private init(){ }
}


public class FSInfo {
    public var fsApiReady = false
    public var namespace = ""

    init(){}

    public init(namespace: String) {
        self.fsApiReady = true
        self.namespace = namespace
    }
}
