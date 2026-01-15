//
//  WorkflowListViewModel.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import Domain

@Observable
class WorkflowRowItem: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let enable: Bool
    let namespace: String
    let queueName: String
    let trigger: WorkflowTrigger?
    let lastTriggeredAt: Date
    let updatedAt: Date
    let nodes: [any Domain.WorkflowNode]

    private let workflow: Workflow

    init(workflow: Workflow) {
        self.workflow = workflow
        self.id = workflow.id
        self.name = workflow.name
        self.enable = workflow.enable
        self.namespace = workflow.namespace
        self.queueName = workflow.queueName
        self.trigger = workflow.trigger
        self.lastTriggeredAt = workflow.lastTriggeredAt
        self.updatedAt = workflow.updatedAt
        self.nodes = workflow.nodes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: WorkflowRowItem, rhs: WorkflowRowItem) -> Bool {
        return lhs.id == rhs.id
    }
}

@Observable
@MainActor
public class WorkflowListViewModel {
    var workflows = [WorkflowRowItem]()
    var isLoading = false
    var isLoadingMore = false

    private var currentPage: Int64 = 1
    private let pageSize: Int64 = 20
    private var hasMore = true
    private var totalCount: Int64 = 0

    let usecase: any WorkflowUseCaseProtocol
    var store: StateStore

    public init(store: StateStore, usecase: any WorkflowUseCaseProtocol) {
        self.store = store
        self.usecase = usecase
    }

    func initWorkflows() async {
        isLoading = true
        workflows.removeAll()
        currentPage = 1

        do {
            let workflowList = try await usecase.listWorkflows(page: currentPage, pageSize: pageSize, sort: nil, order: nil)
            totalCount = Int64(workflowList.count)
            hasMore = Int64(workflowList.count) >= pageSize

            for workflow in workflowList {
                let item = WorkflowRowItem(workflow: workflow)
                workflows.append(item)
            }
        } catch {
            sentAlert("load workflow failed \(error)")
        }

        isLoading = false
    }

    func loadMoreWorkflows() async {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        currentPage += 1

        do {
            let workflowList = try await usecase.listWorkflows(page: currentPage, pageSize: pageSize, sort: nil, order: nil)
            hasMore = Int64(workflowList.count) >= pageSize

            for workflow in workflowList {
                let item = WorkflowRowItem(workflow: workflow)
                workflows.append(item)
            }
        } catch {
            sentAlert("load more workflow failed \(error)")
        }

        isLoadingMore = false
    }
}
