import XCTest
@testable import Domain

final class StoreTests: XCTestCase {

    var store: StateStore!

    override func setUp() {
        super.setUp()
        store = StateStore.shared
        store.resetChildren()
    }

    override func tearDown() {
        store.resetChildren()
        super.tearDown()
    }

    // MARK: - Children Cache Tests

    func testAppendChildren_singleEntry_increasesCount() {
        let entries = [
            createMockCachedEntry(id: 1, uri: "/test/1", name: "entry1")
        ]

        store.appendChildren(entries)

        XCTAssertEqual(store.childrenList.count, 1)
        XCTAssertEqual(store.childrenList.first?.uri, "/test/1")
    }

    func testAppendChildren_multipleEntries_increasesCount() {
        let entries = [
            createMockCachedEntry(id: 1, uri: "/test/1", name: "entry1"),
            createMockCachedEntry(id: 2, uri: "/test/2", name: "entry2")
        ]

        store.appendChildren(entries)

        XCTAssertEqual(store.childrenList.count, 2)
    }

    func testRemoveChildren_existingUri_removesEntry() {
        let entries = [
            createMockCachedEntry(id: 1, uri: "/test/1", name: "entry1"),
            createMockCachedEntry(id: 2, uri: "/test/2", name: "entry2")
        ]
        store.appendChildren(entries)

        store.removeChildren(uris: ["/test/1"])

        XCTAssertEqual(store.childrenList.count, 1)
        XCTAssertNil(store.childrenList.first { $0.uri == "/test/1" })
    }

    func testRemoveChildren_nonExistingUri_keepsOtherEntries() {
        let entries = [
            createMockCachedEntry(id: 1, uri: "/test/1", name: "entry1"),
            createMockCachedEntry(id: 2, uri: "/test/2", name: "entry2")
        ]
        store.appendChildren(entries)

        store.removeChildren(uris: ["/test/3"])

        XCTAssertEqual(store.childrenList.count, 2)
    }

    func testRemoveChildrenRecursively_multipleUris_removesAll() {
        // 直接测试删除多个 URI（不依赖树结构）
        store.appendChildren([
            createMockCachedEntry(id: 1, uri: "/a", name: "a"),
            createMockCachedEntry(id: 2, uri: "/b", name: "b"),
            createMockCachedEntry(id: 3, uri: "/c", name: "c")
        ])

        // 如果没有树结构，只删除直接匹配的 URI
        store.removeChildrenRecursively(uris: ["/a", "/b"])

        // 只有在有完整树结构时才会递归删除，这里验证基础删除
        XCTAssertEqual(store.childrenList.count, 1)
        XCTAssertEqual(store.childrenList.first?.uri, "/c")
    }

    func testResetChildren_clearsAllEntries() {
        let entries = [
            createMockCachedEntry(id: 1, uri: "/test/1", name: "entry1"),
            createMockCachedEntry(id: 2, uri: "/test/2", name: "entry2")
        ]
        store.appendChildren(entries)

        store.resetChildren()

        XCTAssertEqual(store.childrenList.count, 0)
    }

    func testSortChildren_ordersByName() {
        let entries = [
            createMockCachedEntry(id: 1, uri: "/test/z", name: "zebra"),
            createMockCachedEntry(id: 2, uri: "/test/a", name: "apple"),
            createMockCachedEntry(id: 3, uri: "/test/b", name: "banana")
        ]
        store.appendChildren(entries)

        store.sortChildren { $0.name < $1.name }

        XCTAssertEqual(store.childrenList[0].name, "apple")
        XCTAssertEqual(store.childrenList[1].name, "banana")
        XCTAssertEqual(store.childrenList[2].name, "zebra")
    }

    func testUpdateCachedEntry_updatesNameAndUri() {
        let entry = createMockCachedEntry(id: 1, uri: "/test/old", name: "oldName")
        store.appendChildren([entry])

        store.updateCachedEntry(id: 1, newName: "newName", newUri: "/test/new")

        let updated = store.childrenList.first { $0.id == 1 }
        XCTAssertEqual(updated?.name, "newName")
        XCTAssertEqual(updated?.uri, "/test/new")
    }

    // MARK: - Tree Tests

    func testResetTree_buildsTreeFromRoot() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/child1", groupName: "child1", parentID: 1, children: nil),
            MockEntryGroup(id: 3, uri: "/root/child2", groupName: "child2", parentID: 1, children: nil)
        ])

        store.resetTree(root: root)

        XCTAssertEqual(store.treeChildren.count, 2)
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/child1"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/child2"))
    }

    func testResetTree_skipsDotPrefixGroups() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/.hidden", groupName: ".hidden", parentID: 1, children: nil),
            MockEntryGroup(id: 3, uri: "/root/visible", groupName: "visible", parentID: 1, children: nil)
        ])

        store.resetTree(root: root)

        XCTAssertEqual(store.treeChildren.count, 1)
        XCTAssertEqual(store.treeChildren.first?.name, "visible")
    }

    func testAddTreeChildGroup_addsToExistingParent() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: nil)
        store.resetTree(root: root)

        let child = MockEntryGroup(id: 2, uri: "/root/newChild", groupName: "newChild", parentID: 1, children: nil)
        store.addTreeChildGroup(parentUri: "/root", child: child, grandChildren: nil)

        XCTAssertEqual(store.treeChildren.count, 1)
        XCTAssertEqual(store.treeChildren.first?.name, "newChild")
    }

    func testRemoveTreeChildGroup_removesFromParent() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/child1", groupName: "child1", parentID: 1, children: nil),
            MockEntryGroup(id: 3, uri: "/root/child2", groupName: "child2", parentID: 1, children: nil)
        ])
        store.resetTree(root: root)

        store.removeTreeChildGroup(parentUri: "/root", childUri: "/root/child1")

        XCTAssertNil(store.getTreeGroup(uri: "/root/child1"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/child2"))
    }

    func testChangeTreeParent_movesNode_updatesUri() {
        // 创建树结构
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/parentA", groupName: "parentA", parentID: 1, children: [
                MockEntryGroup(id: 3, uri: "/root/parentA/child", groupName: "child", parentID: 2, children: nil)
            ]),
            MockEntryGroup(id: 4, uri: "/root/parentB", groupName: "parentB", parentID: 1, children: nil)
        ])
        store.resetTree(root: root)

        // 将 child 从 parentA 移动到 parentB
        store.changeTreeParent(uri: "/root/parentA/child", newParentUri: "/root/parentB")

        // 验证 child 的新 URI
        XCTAssertNil(store.getTreeGroup(uri: "/root/parentA/child"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/parentB/child"))
    }

    func testChangeTreeParent_preventsLoop() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/parent", groupName: "parent", parentID: 1, children: [
                MockEntryGroup(id: 3, uri: "/root/parent/child", groupName: "child", parentID: 2, children: nil)
            ])
        ])
        store.resetTree(root: root)

        // 尝试将 parent 移动到 child 下（会形成循环）
        store.changeTreeParent(uri: "/root/parent", newParentUri: "/root/parent/child")

        // parent 应该还在原来的位置
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/parent"))
    }

    func testUpdateTreeNode_renamesNode_updatesUri() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/oldName", groupName: "oldName", parentID: 1, children: [
                MockEntryGroup(id: 3, uri: "/root/oldName/child", groupName: "child", parentID: 2, children: nil)
            ])
        ])
        store.resetTree(root: root)

        store.updateTreeNode(uri: "/root/oldName", newName: "newName", newUri: "/root/newName")

        XCTAssertNil(store.getTreeGroup(uri: "/root/oldName"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/newName"))
    }

    func testUpdateTreeNode_updatesDescendantUris() {
        let root = MockEntryGroup(id: 1, uri: "/root", groupName: "root", parentID: 0, children: [
            MockEntryGroup(id: 2, uri: "/root/parent", groupName: "parent", parentID: 1, children: [
                MockEntryGroup(id: 3, uri: "/root/parent/child", groupName: "child", parentID: 2, children: nil)
            ])
        ])
        store.resetTree(root: root)

        store.updateTreeNode(uri: "/root/parent", newName: "renamed", newUri: "/root/renamed")

        // 子节点的 URI 也应该更新
        XCTAssertNil(store.getTreeGroup(uri: "/root/parent/child"))
        XCTAssertNotNil(store.getTreeGroup(uri: "/root/renamed/child"))
    }

    // MARK: - Helpers

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

// MARK: - Mock EntryGroup

private struct MockEntryGroup: EntryGroup {
    let id: Int64
    let uri: String
    let groupName: String
    let parentID: Int64
    let children: [EntryGroup]?
}
