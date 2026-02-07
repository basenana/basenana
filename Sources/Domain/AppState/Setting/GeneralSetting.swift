//
//  GeneralSetting.swift
//  Domain
//
//  Created by Hypo on 2024/12/11.
//

import Foundation
import SwiftUI
import Observation

@Observable
public class GeneralSetting {
    public var inboxFileType: String {
        get {
            access(keyPath: \.inboxFileType)
            return UserDefaults.standard.string(forKey: "org.basenana.general.inboxFileType") ?? "webarchive"
        }
        set {
            withMutation(keyPath: \.inboxFileType) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.general.inboxFileType")
            }
        }
    }

    public init () {}
}
