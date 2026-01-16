//
//  DocumentSetting.swift
//  Domain
//
//  Created by Hypo on 2024/12/11.
//

import Foundation
import SwiftUI
import Observation

@Observable
public class DocumentSetting {
    public var sortUnread: String {
        get {
            access(keyPath: \.sortUnread)
            return UserDefaults.standard.string(forKey: "org.basenana.document.sortUnread") ?? "newest"
        }
        set {
            withMutation(keyPath: \.sortUnread) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.document.sortUnread")
            }
        }
    }

    public var groupBy: String {
        get {
            access(keyPath: \.groupBy)
            return UserDefaults.standard.string(forKey: "org.basenana.document.groupBy") ?? "date"
        }
        set {
            withMutation(keyPath: \.groupBy) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.document.groupBy")
            }
        }
    }

    public var autoRead: Bool {
        get {
            access(keyPath: \.autoRead)
            return UserDefaults.standard.bool(forKey: "org.basenana.document.autoRead")
        }
        set {
            withMutation(keyPath: \.autoRead) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.document.autoRead")
            }
        }
    }

    public var autoTranslate: Bool {
        get {
            access(keyPath: \.autoTranslate)
            return UserDefaults.standard.bool(forKey: "org.basenana.document.autoTranslate")
        }
        set {
            withMutation(keyPath: \.autoTranslate) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.document.autoTranslate")
            }
        }
    }

    public var autoSummary: Bool {
        get {
            access(keyPath: \.autoSummary)
            return UserDefaults.standard.bool(forKey: "org.basenana.document.autoSummary")
        }
        set {
            withMutation(keyPath: \.autoSummary) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.document.autoSummary")
            }
        }
    }

    init() {}
}
