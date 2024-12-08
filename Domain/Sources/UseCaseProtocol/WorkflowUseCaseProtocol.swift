//
//  WorkflowUseCaseProtocol.swift
//  Domain
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import Entities


public protocol WorkflowUseCaseProtocol {
    func listWorkflows() async throws -> [Workflow]
    func listWorkflowJobs(workflow: String) async throws -> [WorkflowJob]
}
