//
//  ColorSchemeSetting.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//


import Foundation
import SwiftUI

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
