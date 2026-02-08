import XCTest
@testable import Domain

final class EntrySyncUseCaseTests: XCTestCase {

    var store: StateStore!
    var syncUseCase: EntrySyncUseCase!

    override func setUp() {
        super.setUp()
        store = StateStore.shared
        syncUseCase = EntrySyncUseCase(store: store)
        store.resetChildren()
    }

    override func tearDown() {
        store.resetChildren()
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

    // MARK: - syncChildrenAfterCreate Tests

    func testSyncChildrenAfterCreate_whenCurrentGroupMatches_addsToChildren() {
        store.currentGroupUri = "/parent"
        let entries = [createMockEntryInfo(id: 1, uri: "/parent/new", name: "new")]

        syncUseCase.syncChildrenAfterCreate(parentUri: "/parent", entries: entries)

        XCTAssertEqual(store.childrenList.count, 1)
        XCTAssertEqual(store.childrenList.first?.name, "new")
    }

    func testSyncChildrenAfterCreate_whenCurrentGroupDoesNotMatch_doesNotAdd() {
        store.currentGroupUri = "/other"
        let entries = [createMockEntryInfo(id: 1, uri: "/parent/new", name: "new")]

        syncUseCase.syncChildrenAfterCreate(parentUri: "/parent", entries: entries)

        XCTAssertEqual(store.childrenList.count, 0)
    }

    // MARK: - syncChildrenAfterDelete Tests

    func testSyncChildrenAfterDelete_whenCurrentGroupMatches_removesEntry() {
        store.currentGroupUri = "/parent"
        store.appendChildren([
            createMockCachedEntry(id: 1, uri: "/parent/toDelete", name: "toDelete"),
            createMockCachedEntry(id: 2, uri: "/parent/toKeep", name: "toKeep")
        ])

        syncUseCase.syncChildrenAfterDelete(parentUri: "/parent", uris: ["/parent/toDelete"])

        XCTAssertEqual(store.childrenList.count, 1)
        XCTAssertEqual(store.childrenList.first?.name, "toKeep")
    }

    func testSyncChildrenAfterDelete_withNilParent_removesEntry() {
        store.appendChildren([
            createMockCachedEntry(id: 1, uri: "/somewhere/entry1", name: "entry1")
        ])

        syncUseCase.syncChildrenAfterDelete(parentUri: nil, uris: ["/somewhere/entry1"])

        XCTAssertEqual(store.childrenList.count, 0)
    }

    // MARK: - syncChildrenAfterMove Tests

    func testSyncChildrenAfterMove_whenCurrentGroupMatches_removesEntry() {
        store.currentGroupUri = "/from"
        store.appendChildren([
            createMockCachedEntry(id: 1, uri: "/from/moving", name: "moving")
        ])

        syncUseCase.syncChildrenAfterMove(uris: ["/from/moving"], fromParent: "/from", toParent: "/to")

        XCTAssertEqual(store.childrenList.count, 0)
    }

    func testSyncChildrenAfterMove_whenCurrentGroupDoesNotMatch_doesNothing() {
        store.currentGroupUri = "/other"
        store.appendChildren([
            createMockCachedEntry(id: 1, uri: "/from/moving", name: "moving")
        ])

        syncUseCase.syncChildrenAfterMove(uris: ["/from/moving"], fromParent: "/from", toParent: "/to")

        XCTAssertEqual(store.childrenList.count, 1)
    }

    // MARK: - syncChildrenAfterRename Tests

    func testSyncChildrenAfterRename_updatesEntry() {
        store.appendChildren([createMockCachedEntry(id: 1, uri: "/old", name: "oldName")])

        syncUseCase.syncChildrenAfterRename(id: 1, newName: "newName", newUri: "/new")

        let updated = store.childrenList.first { $0.id == 1 }
        XCTAssertEqual(updated?.name, "newName")
        XCTAssertEqual(updated?.uri, "/new")
    }

    // MARK: - resetChildren Tests

    func testResetChildren_clearsChildrenList() {
        store.appendChildren([createMockCachedEntry(id: 1, uri: "/test", name: "test")])

        syncUseCase.resetChildren()

        XCTAssertEqual(store.childrenList.count, 0)
    }

    // MARK: - Helpers

    private func createMockEntryInfo(id: Int64, uri: String, name: String) -> MockEntryInfo {
        MockEntryInfo(
            id: id,
            uri: uri,
            name: name,
            kind: "file",
            isGroup: false,
            size: 100,
            parentID: 0,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date()
        )
    }

    private func createMockCachedEntry(id: Int64, uri: String, name: String, isGroup: Bool = false) -> CachedEntry {
        CachedEntry(
            id: id,
            uri: uri,
            name: name,
            kind: isGroup ? "group" : "file",
            isGroup: isGroup,
            size: 100,
            parentID: 0,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date()
        )
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
