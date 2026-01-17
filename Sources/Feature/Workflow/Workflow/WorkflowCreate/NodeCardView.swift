//
//  NodeCardView.swift
//  Workflow
//
//  Created by Hypo on 2025/1/17.
//

import SwiftUI
import Domain

struct NodeCardView: View {
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
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }

    private var headerView: some View {
        HStack {
            Image(systemName: nodeTypeInfo?.icon ?? "questionmark.circle")
                .foregroundColor(colorForType)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(node.name.isEmpty ? "Untitled Node" : node.name)
                    .font(.headline)
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
                pluginParamsSection
            }

            controlFlowSection
        }
        .padding(12)
    }

    private var paramsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Params")
                    .font(.subheadline)
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
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var pluginParamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Plugin Parameters")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }

            if let plugin = nodeTypeInfo?.plugin {
                ForEach(plugin.parameters, id: \.name) { param in
                    pluginParamField(for: param)
                }
            }
        }
    }

    private func pluginParamField(for param: WorkflowPluginParameter) -> some View {
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
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let options = param.options, !options.isEmpty {
                Picker(param.name, selection: Binding(
                    get: { node.pluginParams[param.name] ?? param.defaultValue ?? "" },
                    set: { node.pluginParams[param.name] = $0 }
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
                    get: { node.pluginParams[param.name] ?? param.defaultValue ?? "" },
                    set: { node.pluginParams[param.name] = $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var basicConfigSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Basic Config")
                .font(.subheadline)
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
                    // Initialize plugin params when switching to plugin
                    if typeInfo.isPlugin, let plugin = typeInfo.plugin {
                        var params: [String: String] = [:]
                        for param in plugin.parameters {
                            if let defaultValue = param.defaultValue {
                                params[param.name] = defaultValue
                            }
                        }
                        node.pluginParams = params
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
            // For logic nodes, only output doesn't support next
            return node.type != "output"
        }
        // Plugin nodes typically support next
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

                case "loop":
                    loopControlFlow

                default:
                    EmptyView()
                }
            }
        }
    }

    private var conditionControlFlow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Branches")
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField("CEL expression", text: $node.condition)
                .textFieldStyle(.roundedBorder)

            Text("e.g., {{.output.success}} == true")
                .font(.caption)
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
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                TextField("Value", text: Binding(
                    get: { node.condition },
                    set: { node.condition = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)

                Text("- Match value for branching")
                    .font(.caption)
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
                            .font(.caption)
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
                    .font(.subheadline)
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

    private var loopControlFlow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Matrix")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Define variable mappings for matrix iteration")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach($node.matrix) { $item in
                HStack(spacing: 8) {
                    TextField("Variable", text: $item.key)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)

                    TextField("Template", text: $item.value)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        node.matrix.removeAll { $0.id == item.id }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                node.matrix.append(NodeDefinition.KeyValueItem())
            } label: {
                Label("Add Entry", systemImage: "plus.circle")
            }
            .font(.caption)
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
            NodeCardView(
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
