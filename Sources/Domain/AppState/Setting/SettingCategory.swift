//
//  SettingCategory.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import SwiftUI

public enum SettingCategory: Int, CaseIterable, Hashable {
    case general
    case appearance
    case reading
    case document
    case database
    
    public var display: String{
        switch self {
        case .general:
            return "General"
        case .appearance:
            return "Appearance"
        case .reading:
            return "Reading"
        case .document:
            return "Document"
        case .database:
            return "NanaFS"
        }
    }

    var localizedString: LocalizedStringKey {
        switch self {
        case .general:
            return "SettingCategory_General"
        case .appearance:
            return "SettingCategory_Appearance"
        case .reading:
            return "SettingCategory_Reading"
        case .document:
            return "SettingCategory_Document"
        case .database:
            return "SettingCategory_NanaFS"
        }
    }
}
