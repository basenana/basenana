//
//  MessageListView.swift
//  basenana
//
//  Created by zww on 2024/6/23.
//

import SwiftUI

struct MessageListView: View {
    @Binding var dialoguemodel : DialogueViewModel
    @Environment(\.sendAlert) var sendAlert

    var body: some View {
        VStack{
             // message
             ScrollView(showsIndicators: false) {
                  ForEach(dialoguemodel.messages) { msg in
                       MessageView(message: msg).id(msg.id)
                  }
             }
             .defaultScrollAnchor(.bottomTrailing)
             .padding()
             
             Spacer()
             
             // send msg
             TextField("New Message", text: $dialoguemodel.messageToSend, axis: .vertical)
                  .padding(20)
                  .textFieldStyle(PlainTextFieldStyle())
                  .frame(minHeight: 60, alignment: .center)
                  .background(
                       RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color.DialogBoxBackground)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                  )
                  .onSubmit{
                      Task{
                          do {
                              try await dialoguemodel.sendMessage()
                          } catch {
                              sendAlert("send message error: \(error)")
                          }
                      }
                  }
        }
    }
}
