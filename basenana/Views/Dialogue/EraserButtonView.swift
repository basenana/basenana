//
//  ButtonView.swift
//  basenana
//
//  Created by zww on 2024/5/29.
//

import Foundation
import SwiftUI

struct EraserButtonView: View {
    let roomId: Int64
    
    @State var isEraserHovering = false
    @Binding var messages : [RoomMessageViewModel]
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                do{
                    try service.clearMessage(roomId: roomId)
                } catch {
                }
                messages = []
            }
        } label: {
            if isEraserHovering {
                Image(systemName: "eraser.fill").resizable().frame(width: 20, height: 20)
            } else {
                Image(systemName: "eraser").resizable().frame(width: 20, height: 20)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in isEraserHovering = hovering }
        .overlay(
            Group {
                if isEraserHovering {
                    Text("Clear")
                        .frame(width: 200)
                        .offset(y: -20.0)
                }
            }
        )
    }
}
