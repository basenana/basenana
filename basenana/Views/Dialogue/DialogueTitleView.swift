//
//  DialogueMenuView.swift
//  basenana
//
//  Created by zww on 2024/6/22.
//

import SwiftUI

struct DialogueTitleView: View {
    @Binding var dialoguemodel : DialogueViewModel
    @Binding var openFriday: Bool

    var body: some View {
        HStack {
            Text("Assisted Reading")
                .font(.headline)
                .frame(height: 30)
            
            Spacer()
            
            let propertyModel = dialoguemodel.propertyModel
            if propertyModel.getProperty(k: "org.basenana.friday/ingest")?.value != "finish"{
                IngestButtonView(dialoguemodel: $dialoguemodel)
                    .id("\(String(describing: propertyModel.entryID))/ingestButton")
            }
            
            // button of eraser ..
            EraserButtonView(dialoguemodel: $dialoguemodel)
                .id("\(String(describing: propertyModel.entryID))/eraserButton")
            
            // button of close ..
            CloseButtonView(openFriday: $openFriday)
                .id("\(String(describing: propertyModel.entryID))/closeButton")
        }
    }
}
