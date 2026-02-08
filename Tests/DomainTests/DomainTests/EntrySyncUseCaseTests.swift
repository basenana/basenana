import XCTest
@testable import Domain

final class EntrySyncUseCaseTests: XCTestCase {

    var store: StateStore!
    var syncUseCase: EntrySyncUseCase!

    override func setUp() {
        super.setUp()
        store = StateStore.shared
        syncUseCase = EntrySyncUseCase(store: store)
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - syncTreeAfterCreate Tests

    func testSyncTreeAfterCreate_addsToTree() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: nil)
        store.resetTree(root: root)

        let child = MockEntryGroup(id: 2, uri: "/root/newChild", groupName: "newChild", parentID: 1, children: nil)
        syncUseCase.syncTreeAfterCreate(parentUri: "/root", group: child)

        XCTAssertEqual(store.treeChildren.count, 1)
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/newChild"))
    }

    // MARK: - syncTreeAfterDelete Tests

    func testSyncTreeAfterDelete_removesFromTree() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/child1", groupName: "child1", parentID: 1, children: nil),
            MockEntryGroup(id: 3, uri: "/root/child2", groupName: "child2", parentID: 1, children: nil)
        ])
        store.resetTree(root: root)

        syncUseCase.syncTreeAfterDelete(uris: ["/root/child1"])

        XCTAssertNil(store.getTreeGroup(uri: "/root/child1"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/child2"))
    }

    // MARK: - syncTreeAfterMove Tests

    func testSyncTreeAfterMove_movesNode() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/parentA", groupName: "parentA", parentID: 1, children: [
                MockEntryGroup(id: 3, uri: "/root/parentA/movedChild", groupName: "movedChild", parentID: 2, children: nil)
            ]),
            MockEntryGroup(id: 4, uri: "/root/parentB", groupName: "parentB", parentID: 1, children: nil)
        ])
        store.resetTree(root: root)

        syncUseCase.syncTreeAfterMove(uri: "/root/parentA/movedChild", newParentUri: "/root/parentB")

        XCTAssertNil(store.getTreeGroup(uri: "/root/parentA/movedChild"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/parentB/movedChild"))
    }

    // MARK: - syncTreeAfterRename Tests

    func testSyncTreeAfterRename_updatesNodeAndChildren() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/oldName", groupName: "oldName", parentID: 1, children: [
                MockEntryGroup(id: 3, uri: "/root/oldName/child", groupName: "child", parentID: 2, children: nil)
            ])
        ])
        store.resetTree(root: root)

        syncUseCase.syncTreeAfterRename(uri: "/root/oldName", newName: "newName", newUri: "/root/newName")

        XCTAssertNil(store.getTreeGroup(uri: "/root/oldName"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/newName"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/newName/child"))
    }

    // MARK: - syncChildrenAfterMove Tests

    func testSyncChildrenAfterMove_postsChildrenChangedNotificationForBothParents() {
        // Expect childrenChanged notification for fromParent, toParent, and moved group
        let expectation = XCTestExpectation(description: "childrenChanged notifications should be sent for both parents and moved group")
        expectation.expectedFulfillmentCount = 3

        let observer = NotificationCenter.default.addObserver(
            forName: .childrenChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let change = notification.object as? ChildrenChange {
                // Verify parent URIs and moved group are received
                if change.parentUri == "/from" && change.changeType == .move {
                    expectation.fulfill()
                } else if change.parentUri == "/to" && change.changeType == .create {
                    expectation.fulfill()
                } else if change.parentUri == "/from/moving" && change.changeType == .move {
                    expectation.fulfill()
                }
            }
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterMove(
            uris: ["/from/moving"],
            fromParent: "/from",
            toParent: "/to",
            currentGroupUri: "/other"
        )

        wait(for: [expectation], timeout: 0.5)
    }

    func testSyncChildrenAfterMove_postsCreateChangeTypeForToParent() {
        // Verify toParent receives .create changeType (not .move)
        let expectation = XCTestExpectation(description: "toParent should receive .create changeType")

        let observer = NotificationCenter.default.addObserver(
            forName: .childrenChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let change = notification.object as? ChildrenChange {
                if change.parentUri == "/to" {
                    XCTAssertEqual(change.changeType, .create)
                    expectation.fulfill()
                }
            }
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterMove(
            uris: ["/from/moving"],
            fromParent: "/from",
            toParent: "/to",
            currentGroupUri: nil
        )

        wait(for: [expectation], timeout: 0.5)
    }

    func testSyncChildrenAfterMove_whenCurrentGroupMatches_triggersReopen() {
        // Test: moving "/A" from "" to "/B", currentGroupUri = "/A" should trigger reopen
        let expectation = XCTestExpectation(description: "reopen notification should be sent")

        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("reopenGroup"),
            object: nil,
            queue: .main
        ) { notification in
            if let uris = notification.object as? [String], uris.count == 2 {
                XCTAssertEqual(uris[0], "/A")
                XCTAssertEqual(uris[1], "/B/A")
                expectation.fulfill()
            }
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterMove(
            uris: ["/A"],
            fromParent: "",
            toParent: "/B",
            currentGroupUri: "/A"
        )

        wait(for: [expectation], timeout: 0.5)
    }

    func testSyncChildrenAfterMove_whenCurrentGroupDoesNotMatch_doesNotReopen() {
        // Test: moving "/from/moving" from "/from" to "/to", currentGroupUri = "/other" should NOT trigger reopen
        let expectation = XCTestExpectation(description: "reopen notification should NOT be sent")
        expectation.isInverted = true

        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("reopenGroup"),
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterMove(
            uris: ["/from/moving"],
            fromParent: "/from",
            toParent: "/to",
            currentGroupUri: "/other"
        )

        wait(for: [expectation], timeout: 0.5)
    }

    func testSyncChildrenAfterMove_whenMovingParentOfCurrentGroup_doesNotReopen() {
        // Test: currentGroupUri = "/A/B", moving "/A" to "/A/B/X" should NOT trigger reopen
        // This is the bug fix: moving parent to descendant's path should not reopen
        let expectation = XCTestExpectation(description: "reopen notification should NOT be sent")
        expectation.isInverted = true

        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("reopenGroup"),
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterMove(
            uris: ["/A"],
            fromParent: "",
            toParent: "/A/B",
            currentGroupUri: "/A/B"
        )

        wait(for: [expectation], timeout: 0.5)
    }

    func testSyncChildrenAfterMove_whenCurrentGroupIsNil_doesNotReopen() {
        // Test: moving with nil currentGroupUri should not trigger reopen
        let expectation = XCTestExpectation(description: "reopen notification should NOT be sent")
        expectation.isInverted = true

        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("reopenGroup"),
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterMove(
            uris: ["/A"],
            fromParent: "",
            toParent: "/B",
            currentGroupUri: nil
        )

        wait(for: [expectation], timeout: 0.5)
    }

    func testSyncChildrenAfterMove_whenMovingChild_doesNotReopen() {
        // Test: currentGroupUri = "/A", moving "/A/B" from "/A" to "/X" should NOT reopen "/A"
        let expectation = XCTestExpectation(description: "reopen notification should NOT be sent")
        expectation.isInverted = true

        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("reopenGroup"),
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterMove(
            uris: ["/A/B"],
            fromParent: "/A",
            toParent: "/X",
            currentGroupUri: "/A"
        )

        wait(for: [expectation], timeout: 0.5)
    }

    // MARK: - syncChildrenAfterRename Tests

    func testSyncChildrenAfterRename_postsNotification() {
        // Test that syncChildrenAfterRename posts childrenChanged notification
        let expectation = XCTestExpectation(description: "childrenChanged notification should be sent")

        let observer = NotificationCenter.default.addObserver(
            forName: .childrenChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let change = notification.object as? ChildrenChange {
                XCTAssertEqual(change.changeType, .rename)
                expectation.fulfill()
            }
        }

        defer { NotificationCenter.default.removeObserver(observer) }

        syncUseCase.syncChildrenAfterRename(id: 1, newName: "newName", newUri: "/new")

        wait(for: [expectation], timeout: 0.5)
    }
}

// MARK: - Mock Objects

private struct MockEntryInfo: EntryInfo {
    let id: Int64
    let uri: String
    let name: String
    let kind: String
    let isGroup: Bool
    let size: Int64
    let parentID: Int64
    let createdAt: Date
    let changedAt: Date
    let modifiedAt: Date
    let accessAt: Date

    func toGroup() -> EntryGroup? { nil }
}

private struct MockEntryGroup: EntryGroup {
    let id: Int64
    let uri: String
    let groupName: String
    let parentID: Int64
    let children: [EntryGroup]?
}
