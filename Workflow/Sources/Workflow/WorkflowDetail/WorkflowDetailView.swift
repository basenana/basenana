//
//  WorkflowDetailView.swift
//  Workflow
//
//  Created by Hypo on 2024/12/7.
//

import SwiftUI
import Foundation


public struct WorkflowDetailView: View {
    
    @State private var viewModel: WorkflowDetailViewModel
    @State private var order: [KeyPathComparator<JobItem>] = [.init(\.startAt, order: .reverse)]
    
    public init(viewModel: WorkflowDetailViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack{
            Table(of: JobItem.self, sortOrder: $order) {
                TableColumn("ID", value: \.id)
                TableColumn("Status", value: \.status)
                TableColumn("Message", value: \.message)
                TableColumn("Start At", value: \.startAt) {
                    Text("\($0.startAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                }
                TableColumn("Finish At", value: \.finishAt) {
                    Text("\($0.finishAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                }
            } rows: {
                ForEach(viewModel.jobs, id: \.id) { job in
                    TableRow(job)
                }
            }
        }
        .task { await viewModel.initWorkflowJobs() }
        .padding(10)
        .frame(minWidth: 900)
        .navigationTitle(viewModel.workflowID)
    }
}
