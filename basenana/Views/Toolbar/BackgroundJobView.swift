//
//  BackgroundJobView.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import SwiftUI
import Foundation


struct BackgroundJobView: View {
    @Environment(Store.self) private var store: Store
    
    var body: some View {
        if !store.state.backgroundJob.isEmpty {
            Button(action: {
                store.dispatch(.alert(msg: "not support"))
            }, label: {
                Image(systemName: "hourglass")
            })
        }
    }
}
