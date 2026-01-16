//
//  DatabaseSetting.swift
//  Domain
//
//  Created by Hypo on 2024/11/20.
//

import Foundation
import SwiftUI
import Observation

@Observable
public class DatabaseSetting {
    public var apiURL: String {
        get {
            access(keyPath: \.apiURL)
            return UserDefaults.standard.string(forKey: "org.basenana.nanafs.url") ?? ""
        }
        set {
            withMutation(keyPath: \.apiURL) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.nanafs.url")
            }
        }
    }

    public var apiBearerToken: String {
        get {
            access(keyPath: \.apiBearerToken)
            return UserDefaults.standard.string(forKey: "org.basenana.nanafs.auth.bearerToken") ?? ""
        }
        set {
            withMutation(keyPath: \.apiBearerToken) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.nanafs.auth.bearerToken")
            }
        }
    }

    init() { }
}
