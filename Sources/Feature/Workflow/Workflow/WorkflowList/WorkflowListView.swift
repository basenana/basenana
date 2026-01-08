//
//  WorkflowListView.swift
//  basenana
//
//  Created by Hypo on 2024/6/27.
//

import SwiftUI
import Domain
import Foundation


public struct WorkflowListView: View {
    
    @State private var viewModel: WorkflowListViewModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 180)),
    ]
    
    public init(viewModel: WorkflowListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView{
            LazyVGrid(
                columns: columns, alignment: .center, spacing: 40 ){
                    ForEach(viewModel.workflows){ workflow in
                        
                        Button(action: { gotoDestination(.workflowDetail(workflow: workflow.id)) }){
                            WorkflowItemView(workflow: workflow)
                        }
                        .buttonStyle(.link)
                    }
                }
        }
        .task { await viewModel.initWorkflows() }
        .padding(10)
        .frame(minWidth: 900)
        .navigationTitle("Workflow")
    }
}
