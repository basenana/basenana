//
//  WorkflowPlugin.swift
//  Domain
//
//  Workflow Plugin domain models
//

import Foundation


public protocol WorkflowPlugin {
    var name: String { get }
    var version: String { get }
    var type: String { get }
    var initParameters: [WorkflowPluginParameter] { get }
    var parameters: [WorkflowPluginParameter] { get }
}

public protocol WorkflowPluginParameter {
    var name: String { get }
    var required: Bool { get }
    var defaultValue: String? { get }
    var description: String? { get }
    var options: [String]? { get }
}

public struct WorkflowPluginParameterStruct: WorkflowPluginParameter {
    public var name: String
    public var required: Bool
    public var defaultValue: String?
    public var description: String?
    public var options: [String]?

    public init(name: String, required: Bool, defaultValue: String? = nil, description: String? = nil, options: [String]? = nil) {
        self.name = name
        self.required = required
        self.defaultValue = defaultValue
        self.description = description
        self.options = options
    }
}
