//
//  GroupView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import SwiftUI
import SwiftData

struct GroupView: View{
    var group: GroupModel
    
    @State private var groupViewModel = GroupViewModel()
    @Environment(\.sendAlert) var sendAlert

    var body: some View {
        GeometryReader { geometry in
            VStack{
                VSplitView(){
                    GroupTableView(group: $groupViewModel)
                        .frame(minHeight: 200, maxHeight: .infinity)
                        .task {
                            do {
                                try await groupViewModel.fetchChildren(groupID: group.groupID)
                            } catch {
                                let msg = "fetch group \(group.groupID) error: \(error)"
                                log.error(msg)
                                sendAlert(msg)
                            }
                        }

                    if let doc = groupViewModel.document {
                        DocumentDetailView(entryId: doc.oid)
                            .id("\(doc.oid)/doc")
                            .frame(minHeight: 300, idealHeight: geometry.size.height/2)
                            .layoutPriority(1)
                    }
                }
                .onChange(of: groupViewModel.selection) {
                    Task {
                        do {
                            try await groupViewModel.fetchSelectedDocument()
                        } catch {
                            let msg = "fetch document error: \(error)"
                            log.error(msg)
                            sendAlert(msg)
                        }
                    }
                }
            }
        }
    }
}
