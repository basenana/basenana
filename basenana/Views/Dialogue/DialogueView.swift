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
     @State private var dialoguemodel = DialogueViewModel()
     @Binding var openFriday: Bool
     @Environment(\.sendAlert) var sendAlert
     
     let entryId: Int64
     
     var body: some View {
          VStack {
               DialogueTitleView(dialoguemodel: $dialoguemodel, openFriday: $openFriday)
                    .padding(10)
                    .id("\(dialoguemodel.entryId)/dgTitle")
               
               MessageListView(dialoguemodel: $dialoguemodel)
                    .id("\(dialoguemodel.entryId)/dgMsgs")
                    .task {
                         do {
                              try await dialoguemodel.initDialogue(entryId: entryId)
                         } catch {
                              sendAlert("init dialogue model error: \(error)")
                         }
                    }
          }
          .background(Color.DialogueBackground)
     }
     
}
