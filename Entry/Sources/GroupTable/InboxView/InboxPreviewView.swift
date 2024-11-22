//
//  InboxPreviewView.swift
//  Inbox
//
//  Created by Hypo on 2024/10/14.
//

import SwiftUI
import Foundation
import Entities
import WebPage


@available(macOS 14.0, *)
public struct InboxPreviewView: View {
    var page: WebPage
    
    init(page: WebPage) {
        self.page = page
    }
    
    public var body: some View {
        ReadabilityView(page: page)
    }
}

