//
//  basenanaApp.swift
//  basenana
//
//  Created by Hypo on 2024/2/27.
//

import SwiftUI
import SwiftData

@main
struct basenanaApp: App {
    var body: some Scene {
        let _ = setupLogging()
        WindowGroup {
            MainView()
                .frame(minWidth: 1000, minHeight: 600)
        }
    }
}
