//
//  BackgroundJobView.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import SwiftUI
import Foundation
import AppState


struct BackgroundJobView: View {
    
    @State private var state: StateStore
    
    init(state: StateStore) {
        self.state = state
    }
    
    var body: some View {
        Button(action: {
            state.dispatch(.alert(msg: "not support"))
        }, label: {
            Image(systemName: "hourglass")
        })
    }
}
