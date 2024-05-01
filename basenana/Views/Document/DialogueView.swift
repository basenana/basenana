//
//  DialogueView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI
import SwiftData

let user = "User"
let model = "Assistant"

struct DialogueView: View {
     @Binding var isDrawerOpen: Bool
     let docId: Int64
     let entryId: Int64
     
     @State private var isCloseHovering = false
     @State private var isEraserHovering = false
     @State var newMessage = ""
     @State var waitingMessage = ""
     @State private var room: RoomViewModel?
     @State var messages: [RoomMessageViewModel] = []
     
     var body: some View {
          VStack {
               
               HStack {
                    // dialogue title ..
                    RoundedRectangle(cornerRadius: 10)
                         .fill(Color.DialogBoxBackground)
                         .overlay( Text("Assisted Reading")
                              .font(.headline)
                         )
                         .frame(height: 30)
                    Spacer()
                    
                    // button of eraser ..
                    EraserButton(isEraserHovering: isEraserHovering, isDrawerOpen: $isDrawerOpen, messages: $messages, roomId: room?.id ?? 0)
                    
                    // button of close ..
                    CloseButton(isCloseHovering: isCloseHovering, isDrawerOpen: $isDrawerOpen)
               }
               .padding(10)
               
               ZStack{
                    
                    // gray background
                    RoundedRectangle(cornerRadius: 10).stroke(Color.DialogBoxBackground, lineWidth: 4)
                    
                    VStack{
                         // message
                         ScrollView(showsIndicators: false) {
                              ForEach($messages) { msg in
                                   MessageView(message: msg).id(msg.id)
                              }
                         }
                         .onAppear{
                              room = dialogueService.openRoom(docId: docId, entryId: entryId)
                              let roomMessages = room?.messages ?? []
                              for msg in roomMessages {
                                   messages.append(RoomMessageViewModel(id: msg.id!, sender: msg.sender, message: msg.message, sendAt: msg.sendAt))
                              }
                         }
                         .defaultScrollAnchor(.bottomTrailing)
                         .padding()
                         
                         Spacer()
                         
                         // send msg
                         TextField("New Message", text: $newMessage, axis: .vertical)
                              .padding(20)
                              .textFieldStyle(PlainTextFieldStyle())
                              .frame(minHeight: 60, alignment: .center)
                              .background(
                                   RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.DialogBoxBackground)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 8)
                              )
                              .onSubmit{ Task{ self.sendMessage() }}
                         
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
               }
               
          }
          .background(Color.DialogueBackground)
     }
     
     
     func sendMessage() {
          if !self.newMessage.isEmpty {
               DispatchQueue(label: "org.basenana.room.sendMessage").async {
                    do {
                         let messageNeedToSend = self.newMessage
                         var requestNeedToSave = true
                         var hasApply = false
                         try dialogueService.chatInRoom(
                              roomId: room?.id ?? 0,
                              newRequest: messageNeedToSend,
                              callbackFn: {requestMsg,responseMsg in
                                   if requestNeedToSave && requestMsg.id != nil && requestMsg.id != 0 {
                                        requestNeedToSave = false
                                        messages.append(RoomMessageViewModel(id: requestMsg.id!, sender: requestMsg.sender, message: requestMsg.message, sendAt: requestMsg.sendAt))
                                   }
                                   if let responseId = responseMsg.id, responseId != 0 {
                                        if !hasApply{
                                             messages.append(RoomMessageViewModel(id: responseMsg.id!, sender: responseMsg.sender, message: responseMsg.message, sendAt: responseMsg.sendAt))
                                             hasApply = true
                                        }else{
                                             let count = messages.count > 10 ? 10:messages.count
                                             for i in 0..<count{
                                                  let msg = messages[messages.count-1-i]
                                                  if msg.id == responseMsg.id {
                                                       msg.sender = responseMsg.sender
                                                       msg.message = responseMsg.message
                                                       messages[messages.count-1-i] = msg
                                                       break
                                                  }
                                             }
                                        }
                                   }
                              })
                    } catch {
                         log.error("chat in room failed \(error)")
                    }
                    self.newMessage = ""
               }
          }
     }
}

struct MessageView: View {
     @Binding var message: RoomMessageViewModel
     
     var body: some View {
          let dateFormatter: DateFormatter = {
               let formatter = DateFormatter()
               formatter.dateStyle = .short
               formatter.timeStyle = .medium
               return formatter
          }()
          
          if message.sender.lowercased() == "user" {
               // message of user in right
               HStack {
                    VStack(alignment: .trailing) {
                         HStack{
                              Text(message.sender).font(.headline)
                              Text("😃").font(.title)
                         }
                         Text(message.message)
                              .font(.body)
                              .padding(10)
                              .background(Color.UserMsgBackground)
                              .clipShape(RoundedRectangle(cornerRadius: 10))
                              .textSelection(.enabled)
                         
                         Text(dateFormatter.string(from: message.sendAt))
                              .font(.caption)
                              .foregroundColor(Color.DateColor)
                    }
               }
               .frame(maxWidth: .infinity,alignment: .trailing)
               .padding(.vertical, 5)
          } else {
               // message of robot in left
               HStack {
                    VStack(alignment: .leading) {
                         HStack{
                              Text("🤖").font(.title)
                              Text(message.sender).font(.headline)
                         }
                         Text(message.message)
                              .font(.body)
                              .padding(10)
                              .background(Color.RobotMsgBackground)
                              .clipShape(RoundedRectangle(cornerRadius: 10))
                              .textSelection(.enabled)
                         Text(dateFormatter.string(from: message.sendAt))
                              .font(.caption)
                              .foregroundColor(Color.DateColor)
                    }
               }
               .frame(maxWidth:.infinity, alignment: .leading)
               .padding(.vertical, 5)
          }
     }
}

struct CloseButton: View {
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
                              .background(Color.white)
                              .foregroundColor(.black)
                              .frame(width: 200)
                              .offset(y: -20.0)
                    }
               }
          )
     }
}

struct EraserButton: View {
     @State var isEraserHovering = false
     @Binding var isDrawerOpen: Bool
     @Binding var messages : [RoomMessageViewModel]
     let roomId: Int64
     
     var body: some View {
          Button {
               withAnimation(.easeInOut) {
                    dialogueService.clearMessage(roomId: roomId)
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
                              .background(Color.white)
                              .foregroundColor(.black)
                              .frame(width: 200)
                              .offset(y: -20.0)
                    }
               }
          )
     }
}


#Preview {
     return DialogueView(isDrawerOpen: .constant(true), docId: 100, entryId: 100)
}
