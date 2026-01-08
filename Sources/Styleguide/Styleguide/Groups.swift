// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Foundation


public struct GroupDestDisclosureStyle: DisclosureGroupStyle {
    
    public init(){ }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}
