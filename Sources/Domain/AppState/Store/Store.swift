//
//  Store.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI
import Observation


@Observable
public class StateStore {
    public static var shared = StateStore()

    public var notifications = [String]()
    public var backgroupJobs = [BackgroundJob]()
    public var fsInfo = FSInfo()
    public var setting = Setting.global

    // Global panel visibility states
    public var showInspector: Bool = false
    public var showDocumentView: Bool = false

    // Navigation state
    public var destinations: [Destination] = []

    private init(){ }
}


public class FSInfo: Equatable {
    public var fsApiReady = false

    public init() {}

    public static func == (lhs: FSInfo, rhs: FSInfo) -> Bool {
        return lhs.fsApiReady == rhs.fsApiReady
    }
}
