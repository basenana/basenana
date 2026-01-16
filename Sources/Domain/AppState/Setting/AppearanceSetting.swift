//
//  ColorSchemeSetting.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import SwiftUI
import Observation

@Observable
public class AppearanceSetting {
    public var appearance: String {
        get {
            access(keyPath: \.appearance)
            return UserDefaults.standard.string(forKey: "org.basenana.appearance.appearance") ?? "auto"
        }
        set {
            withMutation(keyPath: \.appearance) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.appearance")
            }
        }
    }

    public var language: String {
        get {
            access(keyPath: \.language)
            return UserDefaults.standard.string(forKey: "org.basenana.appearance.language") ?? "english"
        }
        set {
            withMutation(keyPath: \.language) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.language")
            }
        }
    }

    public var appFont: String {
        get {
            access(keyPath: \.appFont)
            return UserDefaults.standard.string(forKey: "org.basenana.appearance.appFont") ?? "default"
        }
        set {
            withMutation(keyPath: \.appFont) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.appFont")
            }
        }
    }

    public var appFontSize: Int {
        get {
            access(keyPath: \.appFontSize)
            return UserDefaults.standard.integer(forKey: "org.basenana.appearance.appFontSize")
        }
        set {
            withMutation(keyPath: \.appFontSize) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.appFontSize")
            }
        }
    }

    public var unreadReadModel: String {
        get {
            access(keyPath: \.unreadReadModel)
            return UserDefaults.standard.string(forKey: "org.basenana.appearance.document.unreadReadModel") ?? "masonry"
        }
        set {
            withMutation(keyPath: \.unreadReadModel) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.document.unreadReadModel")
            }
        }
    }

    public var markedReadModel: String {
        get {
            access(keyPath: \.markedReadModel)
            return UserDefaults.standard.string(forKey: "org.basenana.appearance.document.markedReadModel") ?? "navigation"
        }
        set {
            withMutation(keyPath: \.markedReadModel) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.document.markedReadModel")
            }
        }
    }

    public var imagePreview: String {
        get {
            access(keyPath: \.imagePreview)
            return UserDefaults.standard.string(forKey: "org.basenana.appearance.document.imagePreview") ?? "large"
        }
        set {
            withMutation(keyPath: \.imagePreview) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.document.imagePreview")
            }
        }
    }

    public var contentPreview: Bool {
        get {
            access(keyPath: \.contentPreview)
            return UserDefaults.standard.bool(forKey: "org.basenana.appearance.document.contentPreview")
        }
        set {
            withMutation(keyPath: \.contentPreview) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.appearance.document.contentPreview")
            }
        }
    }

    public var overColorScheme: ColorScheme? {
        access(keyPath: \.overColorScheme)
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    init() {}
}

public enum ColorSchemeSetting: Int, CaseIterable, Identifiable {
    case dark
    case light
    case system

    public var colorScheme: ColorScheme? {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
        }
    }

    public var display: String {
        switch self {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        case .system:
            return "System"
        }
    }

    public var id: Self {
        self
    }
}
