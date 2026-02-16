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
            chatMessagesView

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
                    ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                        ChatBubbleView(message: message)
                            .id(message.id)
                        if index != viewModel.messages.count - 1 {
                            Divider()
                        }
                    }

                    if viewModel.isStreaming && !viewModel.messages.isEmpty {
                        StreamingIndicatorView()
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
            Button {
                viewModel.closeChat()
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            TextField("Ask Friday anything...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .onSubmit {
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
                    .foregroundColor(viewModel.inputText.isEmpty ? Color.secondary : Color.blue)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.inputText.isEmpty || viewModel.isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

public struct ChatBubbleView: View {
    @ObservedObject public var message: ChatMessage

    public init(message: ChatMessage) {
        self.message = message
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !message.content.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    senderName
                    Markdown(message.content)
                }
                .textSelection(.enabled)
            }
            Text(formatTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
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
        .padding(.leading, 36)
        .padding(.top, 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }
}