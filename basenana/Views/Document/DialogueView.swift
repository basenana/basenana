//
//  DialogueView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI
import SwiftData

struct DialogueView: View {
     @Binding var isDrawerOpen: Bool
     let docId: Int64
     
     @State private var isCloseHovering = false
     @State private var isEraserHovering = false
     @State var newMessage = ""
     @State private var dialogue: DialogueModel?
     @State var messages : [[String:String]]=[]
     
     @EnvironmentObject private var dialogueService: DialogueService
     
     var body: some View {
          VStack {
               
               HStack {
                    // dialogue title ..
                    RoundedRectangle(cornerRadius: 10)
                         .fill(Color(red: 241/255, green: 241/255, blue: 241/255))
                         .overlay( Text("Assisted Reading") )
                         .frame(height: 30)
                    Spacer()
                    
                    // button of eraser ..
                    EraserButton(isEraserHovering: isEraserHovering, isDrawerOpen: $isDrawerOpen, messages: $messages, docId: docId)
                    
                    // button of close ..
                    CloseButton(isCloseHovering: isCloseHovering, isDrawerOpen: $isDrawerOpen)
               }
               .padding(10)
               
               ZStack{
                    
                    // gray background
                    RoundedRectangle(cornerRadius: 10).stroke(Color(red: 241/255, green: 241/255, blue: 241/255), lineWidth: 4)
                    
                    VStack{
                         
                         // message
                         ScrollView {
                              ForEach( messages, id: \.self) { msg in
                                   HStack { MessageView(msg: msg) }
                                        .padding(.vertical, 5)
                              }
                         }
                         .onAppear{
                              dialogue = dialogueService.getDialogue(docId: docId)
                              messages = dialogue?.messages ?? []
                         }
                         .padding()
                         
                         Spacer()
                         
                         // send msg
                         TextField("New Message", text: $newMessage, axis: .vertical)
                              .padding(20)
                              .textFieldStyle(PlainTextFieldStyle())
                              .frame(minHeight: 60, alignment: .center)
                              .background(
                                   RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 241/255, green: 241/255, blue: 241/255))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 8)
                              )
                              .onSubmit{ Task{ self.sendMessage() }}
                         
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
               }
               
          }
          .background(Color.white)
     }
     
     
     func sendMessage() {
          if !newMessage.isEmpty {
               let mockAssisMsg = "I am a mock assistant."
               dialogueService.saveMessage(docId: docId, user: "user", content: newMessage)
               dialogueService.saveMessage(docId: docId, user: "assistant", content: mockAssisMsg)
               messages.append(["user": "User", "content": newMessage])
               messages.append(["user": "Assistant", "content": mockAssisMsg])
               DispatchQueue.main.async {
                    self.newMessage = ""
               }
          }
     }
}

struct MessageView: View {
     @State var msg : [String:String]
     
     var body: some View {
          if msg["user"]?.lowercased() == "user" {
               // message of user in right
               Spacer()
               VStack(alignment: .trailing) {
                    HStack{
                         Text(msg["user"]!).font(.headline)
                         Text("😃").font(.title)
                    }
                    Text(msg["content"]!)
                         .font(.body)
                         .padding(10)
                         .background(Color(red:222/255, green:241/255, blue: 245/255 ))
                         .clipShape(RoundedRectangle(cornerRadius: 10))
                         .textSelection(.enabled)
               }
          } else {
               // message of robot in left
               VStack(alignment: .leading) {
                    HStack{
                         Text("🤖").font(.title)
                         Text(msg["user"]!).font(.headline)
                    }
                    Text(msg["content"]!)
                         .font(.body)
                         .padding(10)
                         .background(Color(red:228/255, green: 228/255, blue:228/255))
                         .clipShape(RoundedRectangle(cornerRadius: 10))
                         .textSelection(.enabled)
               }
               Spacer()
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
     @Binding var messages : [[String:String]]
     let docId: Int64
     
     @EnvironmentObject private var dialogueService: DialogueService
     
     var body: some View {
          Button {
               withAnimation(.easeInOut) {
                    dialogueService.clearMessage(docId: docId)
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
     let config = ModelConfiguration(isStoredInMemoryOnly: true)
     let container = try! ModelContainer(for: DialogueModel.self, configurations: config)
     
     container.mainContext.insert(DialogueModel(id: 100, oid: 100, docid: 100, messages: [["user": "User", "content": "hello"], ["user": "Assistant", "content": "can I help you?"]]))
     
     return DialogueView(isDrawerOpen: .constant(true), docId: 100).environmentObject(DialogueService(modelContext: container.mainContext))
}
