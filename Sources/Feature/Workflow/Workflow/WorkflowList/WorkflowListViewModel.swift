//
//  WorkflowListViewModel.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import Domain

@Observable
@MainActor
public class WorkflowListViewModel {
    var workflows = [WorkflowItem]()
    var isLoading = false

    var store: StateStore
    var usecase: any WorkflowUseCaseProtocol

    public init(store: StateStore, usecase: any WorkflowUseCaseProtocol) {
        self.store = store
        self.usecase = usecase
    }

    func initWorkflows() async {
        isLoading = true
        workflows.removeAll()

        do {
            let workflowList = try await usecase.listWorkflows()
            for workflow in workflowList {
                let item = WorkflowItem(workflow: workflow)
                workflows.append(item)
            }
        } catch {
            sentAlert("load workflow failed \(error)")
        }

        isLoading = false
    }
}
