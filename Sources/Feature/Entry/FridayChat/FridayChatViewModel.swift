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
    @Published public var currentReasoning: String = ""
    @Published public var errorMessage: String?

    @Published public var sessions: [FridaySession] = []
    @Published public var currentSession: FridaySession?
    @Published public var isShowingSessionList: Bool = false
    @Published public var isCreatingSession: Bool = true
    @Published public var sessionListError: String?

    private let fridayUseCase: FridayUseCaseProtocol
    private var sessionId: String?

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

        let assistantPlaceholder = ChatMessage(
            role: .assistant,
            reasoning: "",
            content: "",
            timestamp: Date()
        )
        messages.append(assistantPlaceholder)

        var currentSessionId: String
        var sessionName: String? = nil

        if isCreatingSession && sessionId == nil {
            sessionName = extractSessionName(from: userMessage)

            do {
                let session = try await fridayUseCase.createSession(name: sessionName ?? "")
                self.sessionId = session.id
                currentSessionId = session.id
                self.currentSession = session
                self.isCreatingSession = false
                self.sessions.insert(session, at: 0)
            } catch {
                isStreaming = false
                errorMessage = error.localizedDescription
                addErrorMessage(error: error)
                return
            }
        } else {
            currentSessionId = sessionId ?? UUID().uuidString
            if sessionId == nil {
                self.sessionId = currentSessionId
            }
        }

        let contextEntries = Self.getContextEntries()

        do {
            try await fridayUseCase.chat(
                message: userMessage,
                sessionId: currentSessionId,
                name: sessionName,
                contextEntries: contextEntries
            ) { [weak self] event in
                guard let self = self else { return }
                Task { @MainActor in
                    switch event {
                    case .message(let message):
                        self.updateLastAssistantMessage(
                            reasoning: message.reasoning,
                            content: message.content
                        )
                    case .event(let event):
                        self.handleEvent(event)
                    case .done:
                        self.isStreaming = false
                    }
                }
            }
        } catch {
            isStreaming = false
            errorMessage = error.localizedDescription
            addErrorMessage(error: error)
        }
    }

    func createNewSession() {
        messages = []
        inputText = ""
        isStreaming = false
        currentReasoning = ""
        errorMessage = nil
        sessionId = nil
        currentSession = nil
        isCreatingSession = true
    }

    func loadSessions() async {
        sessionListError = nil
        do {
            sessions = try await fridayUseCase.getSessions()
        } catch {
            sessionListError = error.localizedDescription
        }
    }

    func selectSession(_ session: FridaySession) async {
        isShowingSessionList = false

        messages = []
        inputText = ""
        isStreaming = false
        currentReasoning = ""
        errorMessage = nil

        do {
            let (meta, sessionMessages) = try await fridayUseCase.getSession(id: session.id)
            self.sessionId = meta.id
            self.currentSession = meta

            for message in sessionMessages {
                let role: ChatMessage.Role = message.type == "user" ? .user : .assistant
                let chatMessage = ChatMessage(
                    role: role,
                    reasoning: message.reasoning ?? "",
                    content: message.content,
                    timestamp: message.time
                )
                messages.append(chatMessage)
            }
        } catch {
            errorMessage = "Failed to load session: \(error.localizedDescription)"
            addErrorMessage(error: error)
        }
    }

    func deleteSession(_ session: FridaySession) async {
        do {
            try await fridayUseCase.deleteSession(id: session.id)
            sessions.removeAll { $0.id == session.id }

            if currentSession?.id == session.id {
                messages = []
                inputText = ""
                isStreaming = false
                currentReasoning = ""
                errorMessage = nil
                sessionId = nil
                currentSession = nil
                isCreatingSession = false
            }
        } catch {
            sessionListError = "Failed to delete session: \(error.localizedDescription)"
        }
    }

    private func updateLastAssistantMessage(reasoning: String?, content: String?) {
        guard !messages.isEmpty else { return }

        if let reasoning = reasoning {
            currentReasoning = reasoning
        }

        guard let content = content, !content.isEmpty else { return }

        let lastIndex = messages.count - 1
        if messages[lastIndex].role == .assistant {
            messages[lastIndex].appendContent(content)
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
        sessionId = nil
    }

    func startNewSession() {
        clearChat()
    }

    private static func getContextEntries() -> [String]? {
        let currentUri = StateStore.shared.selectedEntryUri
        let currentGroupUri = StateStore.shared.currentGroupUri

        #if DEBUG
        print("[FridayChat] getContextEntries: selectedEntryUri=\(currentUri ?? "nil"), currentGroupUri=\(currentGroupUri ?? "nil")")
        #endif

        var contextEntries: [String] = []
        if let uri = currentUri, !uri.isEmpty {
            contextEntries.append(uri)
        }
        if let uri = currentGroupUri, !uri.isEmpty && !contextEntries.contains(uri) {
            contextEntries.append(uri)
        }

        #if DEBUG
        print("[FridayChat] getContextEntries: returning \(contextEntries)")
        #endif

        return contextEntries.isEmpty ? nil : contextEntries
    }

    private func extractSessionName(from message: String) -> String {
        let firstLine = message.components(separatedBy: .newlines).first ?? message
        return firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
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
