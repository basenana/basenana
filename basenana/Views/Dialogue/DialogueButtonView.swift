//
//  DialogueButtonView.swift
//  basenana
//
//  Created by zww on 2024/6/23.
//

import Foundation
import SwiftUI

struct IngestButtonView: View {
    @Binding var dialoguemodel : DialogueViewModel
    @Environment(\.sendAlert) var sendAlert

    @State private var isIngestHovering = false
    
    var body: some View {
        Button {
            Task {
                do {
                    try await dialoguemodel.ingestDocument()
                } catch {
                    sendAlert("ingest document error: \(error)")
                }
            }
        } label: {
            let ingestState = dialoguemodel.propertyModel.getProperty(k: "org.basenana.friday/ingest")?.value ?? ""
            if ingestState == "" {
                if isIngestHovering {
                    Image(systemName: "square.and.arrow.down.fill").resizable().frame(width: 20, height: 20)
                } else {
                    Image(systemName: "square.and.arrow.down").resizable().frame(width: 20, height: 20)
                }
            } else if ingestState == "processing" {
                Image(systemName: "goforward").resizable().frame(width: 20, height: 20)
            }
        }
        .disabled(dialoguemodel.propertyModel.getProperty(k: "org.basenana.friday/ingest")?.value ?? "" == "processing")
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in isIngestHovering = hovering }
        .overlay(
            Group {
                if isIngestHovering {
                    let ingestState = dialoguemodel.propertyModel.getProperty(k: "org.basenana.friday/ingest")?.value ?? ""
                    if ingestState == "processing" {
                        Text("Ingesting")
                            .frame(width: 200)
                            .offset(y: -20.0)
                    } else {
                        Text("Ingest")
                            .frame(width: 200)
                            .offset(y: -20.0)
                    }
                }
            }
        )
    }
}

struct EraserButtonView: View {
    @Binding var dialoguemodel: DialogueViewModel

    @State var isEraserHovering = false
    @Environment(\.sendAlert) var sendAlert

    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                dialoguemodel.messages = []
            }
            Task {
                do {
                    try await dialoguemodel.clearMessages()
                } catch {
                    sendAlert("clear messages error: \(error)")
                }
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

struct CloseButtonView: View {
     @State var isCloseHovering = false
     @Binding var openFriday: Bool

     var body: some View {
          Button {
               withAnimation(.easeInOut) { openFriday.toggle() }
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
                              .frame(width: 200)
                              .offset(y: -20.0)
                    }
               }
          )
     }
}
