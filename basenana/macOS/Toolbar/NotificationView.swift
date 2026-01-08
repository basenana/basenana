//
//  NotificationView.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import SwiftUI
import Foundation
import Domain
import Domain


struct NotificationView: View {
    
    @State private var state: StateStore
    
    init(state: StateStore) {
        self.state = state
    }
    
    public var body: some View {
        if !state.notifications.isEmpty {
            Button(action: {
                sentAlert("not support")
            }, label: {
                Image(systemName: "bell")
            })
        }
    }
}
