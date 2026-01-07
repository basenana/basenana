//
//  WorkflowListViewModel.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import AppState
import Entities
import UseCases


@Observable
@MainActor
public class WorkflowListViewModel {

    var workflows = [WorkflowItem]()

    var store: StateStore
    var usecase: any WorkflowUseCaseProtocol

    public init(store: StateStore, usecase: any WorkflowUseCaseProtocol) {
        self.store = store
        self.usecase = usecase
    }
    
    func initWorkflows() async {
        workflows.removeAll()
        
        do {
            let wokflowList = try await usecase.listWorkflows()
            for workflow in wokflowList {
                workflows.append(WorkflowItem(workflow: workflow))
            }
        } catch {
            sentAlert("load workflow failed \(error)")
        }
    }
}
