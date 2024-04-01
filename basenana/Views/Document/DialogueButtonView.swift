//
//  DialogueButtonView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI

struct DialogueButtonView: View {
    @Binding var isDrawerOpen: Bool
    
    var body: some View {
        Button(action: {
            isDrawerOpen.toggle()
        }, label: {
            Image(systemName: "ellipsis.message")
                .resizable()
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(
                    ZStack{
                        Color.white
                            .clipShape(RoundedCorners(tl: 60, tr: 0, bl: 60, br: 0))
                    }
                )
        })
        .padding()
        .offset(x: isDrawerOpen ? -195 : 5, y: 0)
    }
}

#Preview {
    DialogueButtonView(isDrawerOpen: .constant(true))
}
