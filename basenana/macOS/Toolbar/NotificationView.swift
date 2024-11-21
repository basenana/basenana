//
//  NotificationView.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import SwiftUI
import Foundation
import AppState


struct NotificationView: View {
    
    @State private var state: StateStore
    
    init(state: StateStore) {
        self.state = state
    }
    
    var body: some View {
        if !state.notifications.isEmpty {
            Button(action: {
                state.dispatch(.alert(msg: "not support"))
            }, label: {
                Image(systemName: "bell")
            })
        }
    }
}
