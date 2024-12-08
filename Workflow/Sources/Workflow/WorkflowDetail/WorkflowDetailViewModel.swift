//
//  WorkflowDetailViewModel.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class WorkflowDetailViewModel {
    var workflowID: String
    
    var workflow: WorkflowItem? = nil
    var jobs = [JobItem]()

    var store: StateStore
    var usecase: WorkflowUseCaseProtocol
    
    public init(workflow: String, store: StateStore, usecase: WorkflowUseCaseProtocol) {
        self.workflowID = workflow
        self.store = store
        self.usecase = usecase
    }
    
    func initWorkflowJobs() async {
        jobs.removeAll()
        
        do {
            let jobList = try await usecase.listWorkflowJobs(workflow: workflowID)
            print("load workflow \(workflowID) jobs, got \(jobList.count)")
            for job in jobList {
                jobs.append(JobItem(job: job))
            }
        } catch {
            sentAlert("load workflow failed \(error)")
        }
    }
}
