//
//  FridayChatViewModel.swift
//  Feature
//
//  ViewModel for Friday AI Chat functionality
//

import Foundation
import Domain
import Data

@MainActor
public class FridayChatViewModel: ObservableObject {
    @Published public var messages: [ChatMessage] = []
    @Published public var inputText: String = ""
    @Published public var isStreaming: Bool = false
    @Published public var showChat: Bool = false
    @Published public var currentReasoning: String = ""
    @Published public var errorMessage: String?

    private let fridayUseCase: FridayUseCaseProtocol

    public init(fridayUseCase: FridayUseCaseProtocol) {
        self.fridayUseCase = fridayUseCase
    }

    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        errorMessage = nil

        let userMessage = inputText
        inputText = ""
        isStreaming = true

        let userChatMessage = ChatMessage(
            role: .user,
            reasoning: "",
            content: userMessage,
            timestamp: Date()
        )
        messages.append(userChatMessage)

        // 添加助手消息占位符
        let assistantPlaceholder = ChatMessage(
            role: .assistant,
            reasoning: "",
            content: "",
            timestamp: Date()
        )
        messages.append(assistantPlaceholder)

        do {
            try await fridayUseCase.chat(message: userMessage) { [weak self] event in
                guard let self = self else { return }
                print("FridayChatViewModel received event: \(event)")
                Task { @MainActor in
                    switch event {
                    case .message(let message):
                        print("FridayChatViewModel received message: reasoning=\(message.reasoning ?? "nil"), content=\(message.content ?? "nil")")
                        self.updateLastAssistantMessage(
                            reasoning: message.reasoning,
                            content: message.content
                        )
                    case .event(let event):
                        print("FridayChatViewModel received event: \(event)")
                        self.handleEvent(event)
                    case .done:
                        print("FridayChatViewModel received done")
                        self.isStreaming = false
                    }
                }
            }
            print("FridayChatViewModel chat completed")
        } catch {
            print("Friday chat error: \(error.localizedDescription)")
            isStreaming = false
            errorMessage = error.localizedDescription
            addErrorMessage(error: error)
        }
    }

    private func updateLastAssistantMessage(reasoning: String?, content: String?) {
        print("updateLastAssistantMessage called: reasoning=\(reasoning ?? "nil"), content=\(content ?? "nil")")
        guard !messages.isEmpty else {
            print("messages is empty, skipping update")
            return
        }

        if let reasoning = reasoning {
            currentReasoning = reasoning
        }

        guard let content = content, !content.isEmpty else {
            print("content is empty, skipping update")
            return
        }

        // 追加内容到最后一个助手消息
        let lastIndex = messages.count - 1
        if messages[lastIndex].role == .assistant {
            messages[lastIndex].appendContent(content)
            print("Updated bubble with content: \(content), total: \(messages[lastIndex].content)")
        }
    }

    private func handleEvent(_ event: FridayEvent) {
        // Handle tool use events if needed
    }

    private func addErrorMessage(error: Error) {
        let displayMessage: String
        if let apiError = error as? APIError {
            displayMessage = apiError.localizedDescription
        } else {
            displayMessage = "Sorry, I encountered an error: \(error.localizedDescription)"
        }
        let errorChatMessage = ChatMessage(
            role: .assistant,
            reasoning: "",
            content: displayMessage,
            timestamp: Date()
        )
        messages.append(errorChatMessage)
    }

    func clearChat() {
        messages = []
        inputText = ""
        isStreaming = false
        currentReasoning = ""
        showChat = false
    }

    func closeChat() {
        showChat = false
    }
}

public class ChatMessage: Identifiable, ObservableObject {
    public let id: UUID
    public let role: Role
    @Published public var reasoning: String
    @Published public var content: String
    public let timestamp: Date

    public enum Role {
        case user
        case assistant
    }

    public init(id: UUID = UUID(), role: Role, reasoning: String, content: String, timestamp: Date) {
        self.id = id
        self.role = role
        self.reasoning = reasoning
        self.content = content
        self.timestamp = timestamp
    }

    public init(role: Role, reasoning: String, content: String, timestamp: Date) {
        self.id = UUID()
        self.role = role
        self.reasoning = reasoning
        self.content = content
        self.timestamp = timestamp
    }

    public func appendContent(_ newContent: String) {
        self.content += newContent
    }
}
