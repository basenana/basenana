//
//  BackgroundJobView.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import SwiftUI
import Foundation
import Entities
import AppState


struct BackgroundJobView: View {
    
    @State private var state: StateStore
    @State private var showList: Bool = false

    init(state: StateStore) {
        self.state = state
    }
    
    var body: some View {
        if !state.backgroupJobs.isEmpty {
            Button(action: {
                showList.toggle()
            }, label: {
                Image(systemName: "number.circle")
            })
            .popover(isPresented: $showList) {
                List{
                    ForEach(state.backgroupJobs){ j in
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                            VStack(alignment: .leading){
                                Text(j.name).font(.headline)
                                Text(RFC3339Formatter().string(from: j.startAt)).font(.caption2)
                            }
                        }
                        .symbolEffect(.pulse)
                        .padding(5)
                    }
                }
                .listStyle(.sidebar)
                .frame(width: 300, height: 400)
            }
        }
    }
}
