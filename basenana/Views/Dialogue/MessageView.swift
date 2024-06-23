//
//  MessageView.swift
//  basenana
//
//  Created by zww on 2024/5/29.
//

import Foundation
import SwiftUI

struct MessageView: View {
     var message: RoomMessageModel
     
    init(message: RoomMessageModel) {
        self.message = message
    }
    
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

