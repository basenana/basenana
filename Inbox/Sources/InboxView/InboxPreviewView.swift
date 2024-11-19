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
    var viewModel: InboxViewModel
    
    init(viewModel: InboxViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        if let safePage = viewModel.page{
            ReadabilityView(page: safePage)
        }else {
            Text("Loading")
        }
    }
}

