import XCTest
@testable import Domain

final class StoreTests: XCTestCase {

    var store: StateStore!

    override func setUp() {
        super.setUp()
        store = StateStore.shared
    }

    override func tearDown() {
        super.tearDown()
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
}

// MARK: - Mock EntryGroup

private struct MockEntryGroup: EntryGroup {
    let id: Int64
    let uri: String
    let groupName: String
    let parentID: Int64
    let children: [EntryGroup]?
}
