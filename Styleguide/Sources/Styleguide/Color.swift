//
//  Color.swift
//  basenana
//
//  Created by zww on 2024/4/12.
//

import Foundation
import SwiftUI

public extension Color {
    static let UserMsgBackground = Color("userMsgBackground")
    
    static let RobotMsgBackground = Color("robotMsgBackground")
    
    static let CardBackground = Color("cardBackground")
    
    static let DialogBoxBackground = Color("dialogBoxBackground")
    
    static let DateColor = Color("dateColor")

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

