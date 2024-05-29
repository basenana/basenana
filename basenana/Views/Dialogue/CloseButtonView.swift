//
//  CloseButtonView.swift
//  basenana
//
//  Created by zww on 2024/5/29.
//

import Foundation
import SwiftUI

struct CloseButtonView: View {
     @State var isCloseHovering = false
     @Binding var isDrawerOpen: Bool
     
     var body: some View {
          Button {
               withAnimation(.easeInOut) { isDrawerOpen.toggle() }
          } label: {
               if isCloseHovering {
                    Image(systemName: "xmark.circle.fill").resizable().frame(width: 20, height: 20)
               } else {
                    Image(systemName: "xmark.circle").resizable().frame(width: 20, height: 20)
               }
          }
          .buttonStyle(PlainButtonStyle())
          .onHover { hovering in isCloseHovering = hovering }
          .overlay(
               Group {
                    if isCloseHovering {
                         Text("Close")
                              .frame(width: 200)
                              .offset(y: -20.0)
                    }
               }
          )
     }
}
