//
//  Store.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI
import Entities

@Observable
@MainActor
public class StateStore {
    public static var empty = StateStore()
    
    public var destinations = [Destination]()
    public var sidebarSelection: Destination = .mainContent
    public var notifications = [String]()
    public var backgroupJobs = [BackgroundJob]()
    public var fsInfo = FSInfo()
    public var setting = Setting.global
    
    private init(){
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("setFSInfo"),
            object: nil, queue: .main, using: { notification in
                if let info = notification.object as? FSInfo {
                    self.fsInfo = info
                }
            })
    }
    
    public func dispatch(_ action: AppAction) {
        print("recive new aciton \(action)")
        Task {
            if let task = reducer(action: action) {
                do {
                    if let action = try await task.value{
                        dispatch(action)
                    }
                } catch {
                    print("dispatch action \(action) error: \(error)")
                }
            }
        }
    }
}

@available(macOS 14.0, *)
extension StateStore {
    public func binding<Value>(
        for keyPath: KeyPath<StateStore, Value>,
        toAction: @escaping (Value) -> AppAction
    ) -> Binding<Value> {
        Binding<Value>(
            get: { self[keyPath: keyPath] },
            set: { self.dispatch(toAction($0)) }
        )
    }
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
