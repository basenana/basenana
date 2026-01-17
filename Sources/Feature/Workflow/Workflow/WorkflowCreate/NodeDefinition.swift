//
//  NodeDefinition.swift
//  Workflow
//
//  Created by Hypo on 2025/1/17.
//

import Foundation

/// Node 类型定义配置
enum NodeDefinition {
    /// Node 类型
    enum NodeType: String, CaseIterable, Identifiable, Codable {
        case http = "http"
        case condition = "condition"
        case switchType = "switch"
        case loop = "loop"
        case transform = "transform"
        case output = "output"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .http: return "HTTP Request"
            case .condition: return "Condition"
            case .switchType: return "Switch"
            case .loop: return "Loop"
            case .transform: return "Transform"
            case .output: return "Output"
            }
        }

        var description: String {
            switch self {
            case .http: return "Send HTTP requests"
            case .condition: return "Branch based on CEL condition"
            case .switchType: return "Branch based on value matching"
            case .loop: return "Iterate over data matrix"
            case .transform: return "Transform and process data"
            case .output: return "Output result"
            }
        }

        var icon: String {
            switch self {
            case .http: return "network"
            case .condition: return "arrow.triangle.branch"
            case .switchType: return "point.topright.arrow.to.point.bottomleft.squareroot"
            case .loop: return "repeat"
            case .transform: return "arrow.triangle.2.circlepath"
            case .output: return "tray"
            }
        }

        var color: String {
            switch self {
            case .http: return "blue"
            case .condition: return "orange"
            case .switchType: return "purple"
            case .loop: return "green"
            case .transform: return "cyan"
            case .output: return "gray"
            }
        }

        /// 是否支持 Next 字段
        var supportsNext: Bool {
            switch self {
            case .output: return false
            default: return true
            }
        }

        /// 是否显示控制流配置
        var hasControlFlow: Bool {
            switch self {
            case .condition, .switchType, .loop: return true
            default: return false
            }
        }

        /// 默认参数
        var defaultParams: [ParamDefinition] {
            switch self {
            case .http:
                return [
                    ParamDefinition(key: "url", displayName: "URL", required: true, placeholder: "https://api.example.com"),
                    ParamDefinition(key: "method", displayName: "Method", required: false, defaultValue: "GET", options: ["GET", "POST", "PUT", "DELETE", "PATCH"]),
                    ParamDefinition(key: "timeout", displayName: "Timeout (s)", required: false, defaultValue: "30")
                ]
            case .condition:
                return [
                    ParamDefinition(key: "expression", displayName: "CEL Expression", required: true, placeholder: "{{.output.success}} == true")
                ]
            case .switchType:
                return [
                    ParamDefinition(key: "value", displayName: "Value", required: true, placeholder: "{{.output.status}}")
                ]
            case .loop:
                return [
                    ParamDefinition(key: "iterator", displayName: "Iterator", required: true, placeholder: "{{.items}}")
                ]
            case .transform:
                return [
                    ParamDefinition(key: "template", displayName: "Template", required: false, placeholder: "jq expression or template")
                ]
            case .output:
                return [
                    ParamDefinition(key: "format", displayName: "Format", required: false, defaultValue: "json", options: ["json", "text", "xml"])
                ]
            }
        }
    }

    /// 参数定义
    struct ParamDefinition: Identifiable, Codable {
        var id: String { key }
        let key: String
        let displayName: String
        let required: Bool
        let placeholder: String?
        let defaultValue: String?
        let options: [String]?

        init(key: String, displayName: String, required: Bool, placeholder: String? = nil, defaultValue: String? = nil, options: [String]? = nil) {
            self.key = key
            self.displayName = displayName
            self.required = required
            self.placeholder = placeholder
            self.defaultValue = defaultValue
            self.options = options
        }
    }

    /// 控制流配置定义
    struct ControlFlowDefinition: Identifiable, Codable {
        var id: String { type.rawValue }
        let type: ControlFlowType
        let displayName: String
        let description: String

        enum ControlFlowType: String, Codable {
            case condition
            case switchCases
            case matrix
        }

        static var allCases: [ControlFlowDefinition] {
            [
                ControlFlowDefinition(type: .condition, displayName: "Condition", description: "CEL expression for branching"),
                ControlFlowDefinition(type: .switchCases, displayName: "Cases", description: "Value matching branches"),
                ControlFlowDefinition(type: .matrix, displayName: "Matrix", description: "Data iteration matrix")
            ]
        }
    }

    /// 获取节点类型定义
    static func definition(for type: NodeType) -> NodeTypeDefinition {
        NodeTypeDefinition(type: type)
    }

    /// 所有节点类型定义
    static var allNodeTypes: [NodeTypeDefinition] {
        NodeType.allCases.map { NodeTypeDefinition(type: $0) }
    }
}

/// 节点类型完整定义
struct NodeTypeDefinition: Identifiable {
    let id: String
    let type: NodeDefinition.NodeType
    let displayName: String
    let description: String
    let icon: String
    let color: String
    let supportsNext: Bool
    let hasControlFlow: Bool
    let params: [NodeDefinition.ParamDefinition]

    init(type: NodeDefinition.NodeType) {
        self.id = type.rawValue
        self.type = type
        self.displayName = type.displayName
        self.description = type.description
        self.icon = type.icon
        self.color = type.color
        self.supportsNext = type.supportsNext
        self.hasControlFlow = type.hasControlFlow
        self.params = type.defaultParams
    }

    /// 需要显示的控制流配置
    var controlFlowTypes: [NodeDefinition.ControlFlowDefinition] {
        switch type {
        case .condition:
            return [NodeDefinition.ControlFlowDefinition(type: .condition, displayName: "Branches", description: "Define branches based on condition")]
        case .switchType:
            return [NodeDefinition.ControlFlowDefinition(type: .switchCases, displayName: "Cases", description: "Define cases for value matching")]
        case .loop:
            return [NodeDefinition.ControlFlowDefinition(type: .matrix, displayName: "Matrix", description: "Define iteration data matrix")]
        default:
            return []
        }
    }
}

// MARK: - Form Data Types

extension NodeDefinition {
    /// Key-Value 表单项
    struct KeyValueItem: Identifiable, Equatable {
        var id: UUID = UUID()
        var key: String = ""
        var value: String = ""

        init() {}
        init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    /// 分支项（condition 类型用）
    struct BranchItem: Identifiable, Equatable {
        var id: UUID = UUID()
        var branchName: String = ""
        var nodeName: String = ""
    }

    /// Case 项（switch 类型用）
    struct CaseItem: Identifiable, Equatable {
        var id: UUID = UUID()
        var value: String = ""
        var nodeName: String = ""
    }
}
