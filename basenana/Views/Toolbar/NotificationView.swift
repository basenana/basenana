//
//  NotificationView.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import SwiftUI
import Foundation


struct NotificationView: View {
    @Environment(Store.self) private var store: Store
    
    var body: some View {
        Button(action: {
            store.dispatch(.alert(msg: "not support"))
        }, label: {
            Image(systemName: "bell")
        })
    }
}
