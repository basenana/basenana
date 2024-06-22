//
//  EnvironmentKey.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import SwiftUI
import Foundation

struct GetClientSetKey: EnvironmentKey {
    static var defaultValue: ()throws -> ClientSet = { throw ClientError.notLogin }
}

struct SendAlertKey: EnvironmentKey {
    static var defaultValue: (String) -> Void = {
        log.info("send alert \($0) but not succeed")
    }
}

struct GoReadDocumentViewKey: EnvironmentKey {
    static var defaultValue: (DocumentPrespective) -> Void = {
        log.info("goto document view \($0) but not succeed")
    }
}

struct GoGroupListViewKey: EnvironmentKey {
    static var defaultValue: (GroupModel) -> Void = {
        log.info("goto group view \($0.groupID) but not succeed")
    }
}


extension EnvironmentValues {
    
    var getClientSet: ()throws -> ClientSet {
        get { self[GetClientSetKey.self] }
        set { self[GetClientSetKey.self] = newValue }
    }
    
    var sendAlert: (String) -> Void {
        get { self[SendAlertKey.self] }
        set { self[SendAlertKey.self] = newValue }
    }
    
    var goReadDocumentView: (DocumentPrespective) -> Void {
        get { self[GoReadDocumentViewKey.self] }
        set { self[GoReadDocumentViewKey.self] = newValue }
    }
    
    var goGroupListView: (GroupModel) -> Void {
        get { self[GoGroupListViewKey.self] }
        set { self[GoGroupListViewKey.self] = newValue }
    }
}
