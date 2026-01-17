//
//  WorkflowCreateNodeCard.swift
//  Feature
//
//  Created by Hypo on 2025/1/17.
//

import SwiftUI
import Domain

struct WorkflowCreateNodeCard: View {
    let nodeIndex: Int
    @Binding var node: WorkflowCreateViewModel.NodeFormData
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    let onRemove: () -> Void

    let availableNodeNames: [String]
    let availableNodeTypes: [WorkflowCreateViewModel.NodeTypeInfo]

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .contentShape(Rectangle())
                .onTapGesture {
                    onToggleExpanded()
                }

            if isExpanded {
                Divider()
                editorView
            }
        }
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(10)
    }

    private var headerView: some View {
        HStack {
            Image(systemName: nodeTypeInfo?.icon ?? "questionmark.circle")
                .foregroundColor(colorForType)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(node.name.isEmpty ? "Untitled Node" : node.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(node.name.isEmpty ? .secondary : .primary)

                Text(nodeTypeInfo?.displayName ?? "Select Type")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                onRemove()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var nodeTypeInfo: WorkflowCreateViewModel.NodeTypeInfo? {
        availableNodeTypes.first { $0.type == node.type }
    }

    @ViewBuilder
    private var editorView: some View {
        VStack(alignment: .leading, spacing: 16) {
            basicConfigSection

            if node.isLogicNode {
                paramsSection
            } else if !node.type.isEmpty {
                initParamsSection
                inputParamsSection
                matrixSection
            }

            controlFlowSection
        }
        .padding(12)
    }

    private var paramsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Params")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    node.params.append(NodeDefinition.KeyValueItem())
                } label: {
                    Label("Add", systemImage: "plus.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }

            if !node.params.isEmpty {
                ForEach($node.params) { $item in
                    HStack(spacing: 8) {
                        TextField("Key", text: $item.key)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)

                        TextField("Value", text: $item.value)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            node.params.removeAll { $0.id == item.id }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var initParamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Init Parameters")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text("- Plugin initialization config")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()
            }

            if let plugin = nodeTypeInfo?.plugin {
                if plugin.initParameters.isEmpty {
                    Text("No init parameters")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(plugin.initParameters, id: \.name) { param in
                        pluginParamField(for: param, params: $node.initParams)
                    }
                }
            }
        }
    }

    private var inputParamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Input Parameters")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text("- Runtime input for plugin")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()
            }

            if let plugin = nodeTypeInfo?.plugin {
                if plugin.parameters.isEmpty {
                    Text("No input parameters")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(plugin.parameters, id: \.name) { param in
                        pluginParamField(for: param, params: $node.inputParams)
                    }
                }
            }
        }
    }

    private var matrixSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Matrix")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text("- Iterate over array data")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    node.matrix.append(NodeDefinition.KeyValueItem())
                } label: {
                    Label("Add Variable", systemImage: "plus.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }

            Text("Define variable mappings from array elements. Use $.nodeName.output.field.*.subfield syntax.")
                .font(.caption2)
                .foregroundColor(.secondary)

            if !node.matrix.isEmpty {
                ForEach($node.matrix) { $item in
                    HStack(spacing: 8) {
                        TextField("Variable Name", text: $item.key)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)

                        TextField("CEL Expression", text: $item.value)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            node.matrix.removeAll { $0.id == item.id }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func pluginParamField(for param: WorkflowPluginParameter, params: Binding<[String: String]>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(param.name)
                    .font(.caption)

                if param.required {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if let description = param.description {
                    Text("- \(description)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if let options = param.options, !options.isEmpty {
                Picker(param.name, selection: Binding(
                    get: { params.wrappedValue[param.name] ?? param.defaultValue ?? "" },
                    set: { params.wrappedValue[param.name] = $0 }
                )) {
                    Text("Select").tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .textFieldStyle(.roundedBorder)
            } else {
                TextField(param.name, text: Binding(
                    get: { params.wrappedValue[param.name] ?? param.defaultValue ?? "" },
                    set: { params.wrappedValue[param.name] = $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var basicConfigSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Basic Config")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                TextField("Name", text: $node.name)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)

                typePicker

                if supportsNext {
                    nextPicker
                }
            }
        }
    }

    private var typePicker: some View {
        Menu("Type: \(nodeTypeInfo?.displayName ?? "Select")") {
            ForEach(availableNodeTypes) { typeInfo in
                Button {
                    node.type = typeInfo.type
                    node.isLogicNode = !typeInfo.isPlugin
                    if typeInfo.isPlugin, let plugin = typeInfo.plugin {
                        var initParams: [String: String] = [:]
                        var inputParams: [String: String] = [:]
                        for param in plugin.initParameters {
                            if let defaultValue = param.defaultValue {
                                initParams[param.name] = defaultValue
                            }
                        }
                        for param in plugin.parameters {
                            if let defaultValue = param.defaultValue {
                                inputParams[param.name] = defaultValue
                            }
                        }
                        node.initParams = initParams
                        node.inputParams = inputParams
                    }
                } label: {
                    Label(typeInfo.displayName, systemImage: typeInfo.icon)
                }
            }
        }
        .frame(width: 150)
    }

    private var supportsNext: Bool {
        if node.isLogicNode {
            return node.type != "output"
        }
        return true
    }

    private var nextPicker: some View {
        Menu("Next: \(node.next.isEmpty ? "None" : node.next)") {
            Button("None") {
                node.next = ""
            }

            if !availableNodeNames.isEmpty {
                Divider()
                ForEach(availableNodeNames, id: \.self) { name in
                    Button(name) {
                        node.next = name
                    }
                }
            }
        }
        .frame(width: 150)
    }

    private var controlFlowSection: some View {
        Group {
            if node.isLogicNode {
                switch node.type {
                case "condition":
                    conditionControlFlow

                case "switch":
                    switchControlFlow

                default:
                    EmptyView()
                }
            }
        }
    }

    private var conditionControlFlow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Branches")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            TextField("CEL expression", text: $node.condition)
                .textFieldStyle(.roundedBorder)

            Text("e.g., {{.output.success}} == true")
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack {
                Text("true")
                    .font(.caption)
                    .foregroundColor(.secondary)
                branchNextMenu(branchName: "true")
                    .frame(width: 150)
            }

            HStack {
                Text("false")
                    .font(.caption)
                    .foregroundColor(.secondary)
                branchNextMenu(branchName: "false")
                    .frame(width: 150)
            }
        }
    }

    private func branchNextMenu(branchName: String) -> some View {
        Menu("Target: \(getBranchTarget(branchName) ?? "Select")") {
            Button("None") {
                setBranchTarget(branchName, target: "")
            }
            if !availableNodeNames.isEmpty {
                Divider()
                ForEach(availableNodeNames, id: \.self) { name in
                    Button(name) {
                        setBranchTarget(branchName, target: name)
                    }
                }
            }
        }
    }

    private func getBranchTarget(_ branchName: String) -> String? {
        node.branches.first { $0.branchName == branchName }?.nodeName
    }

    private func setBranchTarget(_ branchName: String, target: String) {
        if let index = node.branches.firstIndex(where: { $0.branchName == branchName }) {
            node.branches[index].nodeName = target
        } else {
            var newBranch = NodeDefinition.BranchItem()
            newBranch.branchName = branchName
            newBranch.nodeName = target
            node.branches.append(newBranch)
        }
    }

    private var switchControlFlow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cases")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            HStack {
                TextField("Value", text: Binding(
                    get: { node.condition },
                    set: { node.condition = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)

                Text("- Match value for branching")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            ForEach($node.cases) { $caseItem in
                HStack(spacing: 8) {
                    TextField("Value", text: $caseItem.value)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)

                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)

                    caseNextMenu(for: $caseItem)
                        .frame(width: 150)

                    Button {
                        node.cases.removeAll { $0.id == caseItem.id }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                node.cases.append(NodeDefinition.CaseItem())
            } label: {
                Label("Add Case", systemImage: "plus.circle")
            }
            .font(.caption)

            Divider()

            HStack {
                Text("Default")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Spacer()

                defaultNextMenu
                    .frame(width: 150)
            }
        }
    }

    private func caseNextMenu(for caseItem: Binding<NodeDefinition.CaseItem>) -> some View {
        Menu("Target: \(caseItem.nodeName.wrappedValue.isEmpty ? "Select" : caseItem.nodeName.wrappedValue)") {
            Button("None") {
                caseItem.nodeName.wrappedValue = ""
            }
            if !availableNodeNames.isEmpty {
                Divider()
                ForEach(availableNodeNames, id: \.self) { name in
                    Button(name) {
                        caseItem.nodeName.wrappedValue = name
                    }
                }
            }
        }
    }

    private var defaultNextMenu: some View {
        Menu("Target: \(node.defaultNext.isEmpty ? "Select" : node.defaultNext)") {
            Button("None") {
                node.defaultNext = ""
            }
            if !availableNodeNames.isEmpty {
                Divider()
                ForEach(availableNodeNames, id: \.self) { name in
                    Button(name) {
                        node.defaultNext = name
                    }
                }
            }
        }
    }

    private var colorForType: Color {
        let colorString = nodeTypeInfo?.color ?? "gray"
        switch colorString {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "cyan": return .cyan
        default: return .gray
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            WorkflowCreateNodeCard(
                nodeIndex: 0,
                node: .constant(WorkflowCreateViewModel.NodeFormData(
                    name: "fetch",
                    type: "http",
                    isLogicNode: true
                )),
                isExpanded: true,
                onToggleExpanded: {},
                onRemove: {},
                availableNodeNames: ["parse", "save", "notify"],
                availableNodeTypes: [
                    WorkflowCreateViewModel.NodeTypeInfo(
                        type: "condition",
                        displayName: "Condition",
                        description: "Branch based on CEL",
                        icon: "arrow.triangle.branch",
                        color: "orange"
                    ),
                    WorkflowCreateViewModel.NodeTypeInfo(
                        type: "switch",
                        displayName: "Switch",
                        description: "Branch based on value",
                        icon: "point.topright.arrow.to.point.bottomleft.squareroot",
                        color: "purple"
                    )
                ]
            )
        }
        .padding()
    }
}
