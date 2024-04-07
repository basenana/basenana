//
//  DialogueView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI

struct DialogueView: View {
     @Binding var isDrawerOpen: Bool
     
     @State private var isCloseHovering = false
     @State private var isEraserHovering = false
     @State var newMessage = ""
     @State var messages = [
          Message(user: "User", text: "Hello!"),
          Message(user: "Robot", text: "Hi! How are you?"),
          Message(user: "User", text: "I'm fine, thanks. And you?" ),
          Message(user: "Robot", text: "I'm good too!"),
     ]
     
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
                    Button {
                         withAnimation(.easeInOut) { messages = [] }
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
                    
                    
                    // button of close ..
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
               .padding(10)
               
               ZStack{
                    
                    // gray background
                    RoundedRectangle(cornerRadius: 10).stroke(Color(red: 241/255, green: 241/255, blue: 241/255), lineWidth: 4)
                    
                    VStack{
                         
                         // message
                         ScrollView {
                              ForEach(messages) { msg in
                                   HStack { MessageView(msg: msg) }
                                        .padding(.vertical, 5)
                              }
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
               messages.append(Message(user: "User", text: newMessage))
               DispatchQueue.main.async {
                    self.newMessage = ""
               }
          }
     }
}

struct MessageView: View {
     @State var msg : Message
     
     var body: some View {
          if msg.user == "User" {
               // message of user in right
               Spacer()
               VStack(alignment: .trailing) {
                    HStack{
                         Text(msg.user).font(.headline)
                         Text("😃").font(.title)
                    }
                    Text(msg.text)
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
                         Text(msg.user).font(.headline)
                    }
                    Text(msg.text)
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

struct Message: Identifiable {
     let id = UUID()
     let user: String
     let text: String
}

#Preview {
     DialogueView(isDrawerOpen: .constant(true))
}
