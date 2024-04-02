//
//  DialogueView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI

struct DialogueView: View {
    @Binding var isDrawerOpen: Bool
    
    var body: some View {
        VStack {
            Text("dialogue content")
                .padding(10)
        }
        .background(Color.white)
        .frame( width: 200)
    }
}

#Preview {
    DialogueView(isDrawerOpen: .constant(true))
}
