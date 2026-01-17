//
//  WorkflowPlugin.swift
//  Data
//
//  Workflow Plugin API models
//

import Foundation
import Domain


public struct APIWorkflowPlugin: WorkflowPlugin {
    public var name: String
    public var version: String
    public var type: String
    public var parameters: [WorkflowPluginParameter]

    public init(name: String, version: String, type: String, parameters: [WorkflowPluginParameter]) {
        self.name = name
        self.version = version
        self.type = type
        self.parameters = parameters
    }

    init(from dto: WorkflowPluginDTO) {
        self.name = dto.name
        self.version = dto.version
        self.type = dto.type
        self.parameters = dto.parameters?.map { paramDTO in
            WorkflowPluginParameterStruct(
                name: paramDTO.name,
                required: paramDTO.required,
                defaultValue: paramDTO.defaultValue,
                description: paramDTO.description,
                options: paramDTO.options
            )
        } ?? []
    }
}
