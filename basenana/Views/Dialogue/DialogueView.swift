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
     let docId: Int64
     let entryId: Int64
     @Binding var isDrawerOpen: Bool

     @State private var isCloseHovering = false
     @State private var isEraserHovering = false
     @State var newMessage = ""
     @State var waitingMessage = ""
     @State private var room: RoomModel? = nil
     @State var messages: [RoomMessageViewModel] = []
     @State private var ingestState = ""
     
     var body: some View {
          VStack {
               
               HStack {
                    // dialogue title ..
                    Text("Assisted Reading")
                         .font(.headline)
                         .frame(height: 30)
                    
                    Spacer()
                    
                    if ingestState != "finish"{
                         IngestButtonView(ingestState: $ingestState, entryId: entryId)
                              .id("\(String(describing: room?.id))/ingestButton")
                    }
                    
                    // button of eraser ..
                    EraserButtonView(roomId: room?.id ?? 0, isEraserHovering: isEraserHovering, messages: $messages)
                         .id("\(String(describing: room?.id))/eraserButton")
                    
                    // button of close ..
                    CloseButtonView(isCloseHovering: isCloseHovering, isDrawerOpen: $isDrawerOpen)
                         .id("\(String(describing: room?.id))/closeButton")
               }
               .onAppear{
                    do {
                         let entry = try service.getEntry(entryID: entryId)
                         for entryProperty in entry.properties {
                              if entryProperty.key == "org.basenana.friday/ingest" {
                                   ingestState = entryProperty.value
                              }
                         }
                    } catch {
                    }
               }
               .padding(10)
               
               VStack{
                    // message
                    ScrollView(showsIndicators: false) {
                         ForEach($messages) { msg in
                              MessageView(message: msg).id(msg.id)
                         }
                    }
                    .onAppear{
                         do {
                              room = try service.openRoom(docId: docId, entryId: entryId)
                         } catch {
                         }
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
                              RoundedRectangle(cornerRadius: 15, style: .continuous)
                                   .fill(Color.DialogBoxBackground)
                                   .padding(.vertical, 8)
                                   .padding(.horizontal, 8)
                         )
                         .onSubmit{ Task{ self.sendMessage() }}
                    
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
                         try service.chatInRoom(
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

#Preview {
     return DialogueView( docId: 100, entryId: 100, isDrawerOpen: .constant(true))
}
