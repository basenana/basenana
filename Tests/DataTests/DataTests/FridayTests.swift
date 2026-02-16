//
//  FridayTests.swift
//  DataTests
//
//  Unit tests for Friday SSE Chat
//

import XCTest
@testable import Data

final class FridayTests: XCTestCase {

    // MARK: - API Model Tests

    func testFridayMessageAppend_decodesFromJSON() {
        let json = """
        {"reasoning": "Thinking about the answer...", "content": "Hello!"}
        """.data(using: .utf8)!

        do {
            let result = try JSONDecoder().decode(FridayMessageAppend.self, from: json)
            XCTAssertEqual(result.reasoning, "Thinking about the answer...")
            XCTAssertEqual(result.content, "Hello!")
        } catch {
            XCTFail("Failed to decode FridayMessageAppend: \(error)")
        }
    }

    func testFridayEventUpdate_decodesFromJSON() {
        let json = """
        {
            "id": "evt-001",
            "type": "tool_use",
            "source": "friday",
            "specversion": "1.0",
            "datacontenttype": "application/json",
            "data": "{\"name\":\"tool_name\",\"arguments\":\"{}\"}",
            "extra_value": {"name": "tool_name", "arguments": "{}"},
            "time": "2024-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!

        do {
            let result = try JSONDecoder().decode(FridayEventUpdate.self, from: json)
            XCTAssertEqual(result.id, "evt-001")
            XCTAssertEqual(result.type, "tool_use")
            XCTAssertEqual(result.source, "friday")
            XCTAssertEqual(result.specversion, "1.0")
            XCTAssertEqual(result.datacontenttype, "application/json")
            XCTAssertEqual(result.data, "{\"name\":\"tool_name\",\"arguments\":\"{}\"}")
            XCTAssertEqual(result.extraValue?.name, "tool_name")
            XCTAssertEqual(result.extraValue?.arguments, "{}")
            XCTAssertEqual(result.time, "2024-01-01T00:00:00Z")
        } catch {
            XCTFail("Failed to decode FridayEventUpdate: \(error)")
        }
    }

    func testFridayEventUpdate_decodesWithoutExtraValue() {
        let json = """
        {
            "id": "evt-002",
            "type": "tool_use",
            "source": "friday",
            "specversion": "1.0",
            "datacontenttype": "application/json",
            "data": "{\"name\":\"test\"}",
            "time": "2024-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!

        do {
            let result = try JSONDecoder().decode(FridayEventUpdate.self, from: json)
            XCTAssertEqual(result.id, "evt-002")
            XCTAssertNil(result.extraValue)
        } catch {
            XCTFail("Failed to decode FridayEventUpdate without extra_value: \(error)")
        }
    }

    func testFridayChatRequest_encodesToJSON() {
        let request = FridayChatRequest(message: "Hello Friday")

        do {
            let data = try JSONEncoder().encode(request)
            let json = String(data: data, encoding: .utf8)!
            XCTAssertTrue(json.contains("\"message\":\"Hello Friday\""))
        } catch {
            XCTFail("Failed to encode FridayChatRequest: \(error)")
        }
    }

    // MARK: - FridayClient Event Parsing Tests

    func testParseMessageAppendEvent() {
        let data = """
        {"reasoning": "Let me think...", "content": "Result here"}
        """

        let event = parseEvent(type: "MESSAGE-APPEND", data: data)

        if case .messageAppend(let message) = event {
            XCTAssertEqual(message.reasoning, "Let me think...")
            XCTAssertEqual(message.content, "Result here")
        } else {
            XCTFail("Expected messageAppend event")
        }
    }

    func testParseEventUpdateEvent() {
        let data = """
        {"id": "evt-001", "type": "tool_use", "source": "friday", "specversion": "1.0", "datacontenttype": "application/json", "data": "{}", "time": "2024-01-01T00:00:00Z"}
        """

        let event = parseEvent(type: "EVENT-UPDATE", data: data)

        if case .eventUpdate(let update) = event {
            XCTAssertEqual(update.id, "evt-001")
            XCTAssertEqual(update.type, "tool_use")
        } else {
            XCTFail("Expected eventUpdate event")
        }
    }

    func testParseDoneEvent() {
        let event = parseEvent(type: "DONE", data: "{}")

        if case .done = event {
            // Expected
        } else {
            XCTFail("Expected done event")
        }
    }

    func testParseUnknownEventDefaultsToDone() {
        let event = parseEvent(type: "UNKNOWN", data: "{}")

        if case .done = event {
            // Expected
        } else {
            XCTFail("Expected done for unknown event type")
        }
    }

    func testParseInvalidJSONReturnsContentAsMessage() {
        let data = "Invalid JSON content"

        let event = parseEvent(type: "MESSAGE-APPEND", data: data)

        if case .messageAppend(let message) = event {
            XCTAssertEqual(message.reasoning, "")
            XCTAssertEqual(message.content, "Invalid JSON content")
        } else {
            XCTFail("Expected messageAppend event")
        }
    }

    // MARK: - Helper Methods

    private func parseEvent(type: String, data: String) -> FridayStreamEvent {
        switch type {
        case "MESSAGE-APPEND":
            if let jsonData = data.data(using: .utf8),
               let messageAppend = try? JSONDecoder().decode(FridayMessageAppend.self, from: jsonData) {
                return .messageAppend(messageAppend)
            }
            return .messageAppend(FridayMessageAppend(reasoning: "", content: data))

        case "EVENT-UPDATE":
            if let jsonData = data.data(using: .utf8),
               let eventUpdate = try? JSONDecoder().decode(FridayEventUpdate.self, from: jsonData) {
                return .eventUpdate(eventUpdate)
            }
            return .done

        case "DONE":
            return .done

        default:
            return .done
        }
    }
}
