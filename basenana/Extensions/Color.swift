//
//  Color.swift
//  basenana
//
//  Created by zww on 2024/4/12.
//

import Foundation
import SwiftUI

extension Color {
    static func UserMsgBackground() -> Color {
        Color("userMsgBackground")
    }
    
    static func RobotMsgBackground() -> Color {
        Color("robotMsgBackground")
    }
    
    static func DialogueBackground() -> Color {
        Color("dialogueBackground")
    }
    
    static func DialogBoxBackground() -> Color {
        Color("dialogBoxBackground")
    }
    
#if os(macOS)
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
#else
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
#endif
}

