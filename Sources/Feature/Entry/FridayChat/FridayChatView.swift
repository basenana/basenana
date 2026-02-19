//
//  FridayChatView.swift
//  Feature
//
//  Friday AI Chat UI Component with SSE streaming support
//

import SwiftUI
import Domain
import MarkdownUI

public struct FridayChatView: View {
    @ObservedObject public var viewModel: FridayChatViewModel
    @FocusState private var isInputFocused: Bool

    public init(viewModel: FridayChatViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.messages.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStackLayout(alignment: .leading) {
                        Text(" _")
                        Text("//\\")
                        Text("V  \\")
                        Text(" \\  \\_")
                        Text("  \\,'.`-.")
                        Text("   |\\ `. `.")
                        Text("   ( \\  `. `-.                        _,.-:\\")
                        Text("    \\ \\   `.  `-._             __..--' ,-';/")
                        Text("     \\ `.   `-.   `-..___..---'   _.--' ,'/")
                        Text("      `. `.    `-._        __..--'    ,' /")
                        Text("        `. `-_     ``--..''       _.-' ,'")
                        Text("          `-_ `-.___        __,--'   ,'")
                        Text("             `-.__  `----\"\"\"    __.-'")
                        Text("                  `--..____..--'")
                    }
                    .font(.system(size: 14, weight: .thin, design: .monospaced))
                    .foregroundColor(.gray)

                    Spacer()
                }
            }else{
                chatMessagesView
            }

            inputArea
        }
        .onAppear {
            isInputFocused = true
        }
    }

    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    let isLastAssistantMessage = viewModel.messages.last?.role == .assistant
                    ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                        let showStreaming = isLastAssistantMessage &&
                                          index == viewModel.messages.count - 1 &&
                                          viewModel.isStreaming
                        ChatBubbleView(message: message, isStreaming: showStreaming)
                            .id(message.id)
                        if index != viewModel.messages.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                Task { @MainActor in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                Task { @MainActor in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    private var inputArea: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField("Ask Friday anything...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(5)
                    .focused($isInputFocused)
                    .onSubmit {
                        guard !viewModel.isStreaming else { return }
                        Task {
                            await viewModel.sendMessage()
                        }
                    }

                Button {
                    Task {
                        await viewModel.sendMessage()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.body)
                        .foregroundColor(viewModel.inputText.isEmpty ? Color.secondary : Color.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.inputText.isEmpty || viewModel.isStreaming)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

public struct ChatBubbleView: View {
    @ObservedObject public var message: ChatMessage
    public var isStreaming: Bool

    public init(message: ChatMessage, isStreaming: Bool = false) {
        self.message = message
        self.isStreaming = isStreaming
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    senderName
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Markdown(message.content)

                    if isStreaming {
                        StreamingIndicatorView()
                    }

                    HStack(alignment: .bottom, spacing: 4) {
                        Spacer()
                        Button {
                            copyToClipboard()
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .textSelection(.enabled)
            }
        }
        .padding(.vertical, 12)
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.content, forType: .string)
    }

    private var senderName: some View {
        Text(message.role == .user ? "You" : "Friday")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(message.role == .user ? .blue : .purple)
            .frame(width: 60, alignment: .leading)
    }

    private func formatTime(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}

public struct StreamingIndicatorView: View {
    @State private var animationPhase: Int = 0

    public init() {}

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.secondary)
                    .frame(width: 6, height: 6)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
            }
        }
        .padding(.top, 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }
}
