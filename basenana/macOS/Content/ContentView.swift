//
//  Container+Injection.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import SwiftUI
import Swinject
import AppState


struct macOSContentView: View {
    let state = StateStore.empty
    
    var body: some View {
        Text("Hello")
    }
}
