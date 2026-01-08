//
//  ColorSchemeSetting.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//


import Foundation
import SwiftUI

public class AppearanceSetting {
    @AppStorage("org.basenana.appearance.appearance", store: UserDefaults.standard)
    public var appearance: String = "auto" // light/dark/auto
    
    @AppStorage("org.basenana.appearance.language", store: UserDefaults.standard)
    public var language: String = "english"
    
    @AppStorage("org.basenana.appearance.appFont", store: UserDefaults.standard)
    public var appFont: String = "default"
    @AppStorage("org.basenana.appearance.appFontSize", store: UserDefaults.standard)
    public var appFontSize: Int = 1
    
    @AppStorage("org.basenana.appearance.document.unreadReadModel", store: UserDefaults.standard)
    public var unreadReadModel: String = "masonry"
    @AppStorage("org.basenana.appearance.document.markedReadModel", store: UserDefaults.standard)
    public var markedReadModel: String = "navigation"
    @AppStorage("org.basenana.appearance.document.imagePreview", store: UserDefaults.standard)
    public var imagePreview: String = "large" // large/small/none
    @AppStorage("org.basenana.appearance.document.contentPreview", store: UserDefaults.standard)
    public var contentPreview: Bool = true
    
    public var overColorScheme: ColorScheme? {
        switch appearance {
        case "light":
            return .light
        case "dart":
            return .dark
        default:
            return nil
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
