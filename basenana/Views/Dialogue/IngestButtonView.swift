//
//  IngestButtonView.swift
//  basenana
//
//  Created by zww on 2024/5/29.
//

import Foundation
import SwiftUI

struct IngestButtonView: View {
     @State var isIngestHovering = false
     @Binding var ingestState: String
     let entryId: Int64
     
     var body: some View {
          Button {
               withAnimation(.easeInOut) {
                    documentService.ingestDocument(entryId: entryId)
                    DispatchQueue(label: "org.basenana.room.syncIngest").async {
                         while true {
                              if let entry = entryService.getEntry(entryID: entryId) {
                                   for entryProperty in entry.properties {
                                        if entryProperty.key == "org.basenana.friday/ingest" {
                                             ingestState = entryProperty.value
                                             if entryProperty.value == "finish" {
                                                  return
                                             }
                                        }
                                   }
                              }
                              Thread.sleep(forTimeInterval: 1)
                         }
                    }
               }
          } label: {
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
          .disabled(ingestState == "processing")
          .buttonStyle(PlainButtonStyle())
          .onHover { hovering in isIngestHovering = hovering }
          .overlay(
               Group {
                    if isIngestHovering {
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
