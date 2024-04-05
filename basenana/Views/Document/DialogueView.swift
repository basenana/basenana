//
//  DialogueView.swift
//  basenana
//
//  Created by zww on 2024/4/1.
//

import SwiftUI

struct DialogueView: View {
    @Binding var isDrawerOpen: Bool
    
    @State private var isHovering = false
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
                    .overlay(
                        Text("对话主题") // FIXME: set theme of doc dialogue
                    )
                    .frame(height: 30)
                
                Spacer()
                
                // button of close ..
                Button {
                    withAnimation(.easeInOut) { isDrawerOpen.toggle() }
                } label: {
                    if isHovering {
                        Image(systemName: "xmark.circle.fill").resizable().frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "xmark.circle").resizable().frame(width: 20, height: 20)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in isHovering = hovering }
            }
            .padding(.top, 5)
            .padding(.vertical, 2)
            
            ZStack{
                
                // gray background
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 241/255, green: 241/255, blue: 241/255), lineWidth: 4)
                
                VStack{
                    
                    // message
                    ScrollView {
                        ForEach(messages) { msg in
                            HStack { MessageView(msg: msg) }
                                .padding(.vertical, 5)
                        }
                    }
                    .padding()
                    
                    // send msg
                    HStack {
                        TextField("New message", text: $newMessage, onCommit: {
                            Task {
                                self.sendMessage()
                            }
                        })
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        
                        
                        Button(action: {
                            self.sendMessage()
                        }) {
                            Image(systemName:"paperplane")
                            Text("Send")
                        }
                        
                    }
                    .padding(10)
                    
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
                    Text(msg.user)
                        .font(.headline)
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                Text(msg.text)
                    .font(.body)
                    .padding(10)
                    .background(Color(red:222/255, green:241/255, blue: 245/255 ))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        } else {
            // message of robot in left
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text(msg.user)
                        .font(.headline)
                }
                Text(msg.text)
                    .font(.body)
                    .padding(10)
                    .background(Color(red:228/255, green: 228/255, blue:228/255))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
