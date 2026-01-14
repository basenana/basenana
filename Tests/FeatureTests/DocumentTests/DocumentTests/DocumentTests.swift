import XCTest
@testable import Feature
@testable import Domain

final class DocumentTests: XCTestCase {

    // MARK: - Pagination Tests

    func testPagination_defaultValues() {
        let pagination = Pagination()

        XCTAssertEqual(pagination.page, 0)
        XCTAssertEqual(pagination.pageSize, 20)
    }

    func testPagination_customValues() {
        var pagination = Pagination()
        pagination.page = 5
        pagination.pageSize = 50

        XCTAssertEqual(pagination.page, 5)
        XCTAssertEqual(pagination.pageSize, 50)
    }

    // MARK: - DocumentUpdate Tests

    func testDocumentUpdate_defaultInit() {
        let update = DocumentUpdate()

        XCTAssertNil(update.title)
        XCTAssertNil(update.author)
        XCTAssertNil(update.year)
        XCTAssertNil(update.source)
        XCTAssertNil(update.abstract)
        XCTAssertNil(update.keywords)
        XCTAssertNil(update.notes)
        XCTAssertNil(update.url)
        XCTAssertNil(update.headerImage)
        XCTAssertNil(update.marked)
        XCTAssertNil(update.unread)
    }

    func testDocumentUpdate_withMarkedState() {
        var update = DocumentUpdate()
        update.marked = true

        XCTAssertTrue(update.marked == true)
    }

    func testDocumentUpdate_withUnreadState() {
        var update = DocumentUpdate()
        update.unread = false

        XCTAssertFalse(update.unread == true)
    }

    func testDocumentUpdate_withTitleAndAuthor() {
        var update = DocumentUpdate()
        update.title = "Test Title"
        update.author = "Test Author"

        XCTAssertEqual(update.title, "Test Title")
        XCTAssertEqual(update.author, "Test Author")
    }

    func testDocumentUpdate_withAllMetadataFields() {
        var update = DocumentUpdate()
        update.title = "Full Title"
        update.author = "Author Name"
        update.year = "2024"
        update.source = "Journal of Testing"
        update.abstract = "This is an abstract"
        update.keywords = ["test", "swift", "xcode"]
        update.notes = "Personal notes"
        update.url = "https://example.com/article"
        update.headerImage = "https://example.com/header.jpg"
        update.marked = true
        update.unread = false

        XCTAssertEqual(update.title, "Full Title")
        XCTAssertEqual(update.author, "Author Name")
        XCTAssertEqual(update.year, "2024")
        XCTAssertEqual(update.source, "Journal of Testing")
        XCTAssertEqual(update.abstract, "This is an abstract")
        XCTAssertEqual(update.keywords?.count, 3)
        XCTAssertEqual(update.notes, "Personal notes")
        XCTAssertEqual(update.url, "https://example.com/article")
        XCTAssertEqual(update.headerImage, "https://example.com/header.jpg")
        XCTAssertTrue(update.marked == true)
        XCTAssertFalse(update.unread == true)
    }

    // MARK: - DocumentFilter Default Values

    func testDocumentFilter_defaultsToEmpty() {
        let filter = DocumentFilter()

        XCTAssertNil(filter.unread)
        XCTAssertNil(filter.marked)
        XCTAssertNil(filter.search)
        XCTAssertNil(filter.page)
    }

    // MARK: - Pagination Boundary Values

    func testPagination_pageZero() {
        var pagination = Pagination()
        pagination.page = 0

        XCTAssertEqual(pagination.page, 0)
    }

    func testPagination_pageSizeBoundary() {
        var pagination = Pagination()
        pagination.pageSize = 1
        pagination.pageSize = 100

        XCTAssertEqual(pagination.pageSize, 100)
    }

    // MARK: - DocumentUpdate State Transitions

    func testDocumentUpdate_markStateToggle() {
        var update = DocumentUpdate()

        XCTAssertNil(update.marked)

        update.marked = true
        XCTAssertTrue(update.marked == true)

        update.marked = false
        XCTAssertFalse(update.marked == true)
    }

    func testDocumentUpdate_unreadStateToggle() {
        var update = DocumentUpdate()

        XCTAssertNil(update.unread)

        update.unread = true
        XCTAssertTrue(update.unread == true)

        update.unread = false
        XCTAssertFalse(update.unread == true)
    }

    // MARK: - DocumentFilter Search

    func testDocumentFilter_searchWithWhitespace() {
        var filter = DocumentFilter()
        filter.search = "  test query  "

        XCTAssertEqual(filter.search, "  test query  ")
    }

    func testDocumentFilter_searchEmptyString() {
        var filter = DocumentFilter()
        filter.search = ""

        XCTAssertEqual(filter.search, "")
    }

    func testDocumentFilter_searchNil() {
        let filter = DocumentFilter()

        XCTAssertNil(filter.search)
    }

    // MARK: - DocumentUseCase Filter Building Logic

    func testDocumentFilter_buildUnreadFilter() {
        var filter = DocumentFilter()
        filter.unread = true
        filter.order = .createdAt
        filter.orderDesc = true

        XCTAssertTrue(filter.unread == true)
        XCTAssertEqual(filter.order, .createdAt)
        XCTAssertTrue(filter.orderDesc == true)
    }

    func testDocumentFilter_buildMarkedFilter() {
        var filter = DocumentFilter()
        filter.marked = true
        filter.order = .createdAt
        filter.orderDesc = true

        XCTAssertTrue(filter.marked == true)
        XCTAssertEqual(filter.order, .createdAt)
        XCTAssertTrue(filter.orderDesc == true)
    }

    func testDocumentFilter_buildSearchFilter() {
        var filter = DocumentFilter()
        filter.search = "swift"
        filter.order = .createdAt
        filter.orderDesc = true

        XCTAssertEqual(filter.search, "swift")
        XCTAssertEqual(filter.order, .createdAt)
        XCTAssertTrue(filter.orderDesc == true)
    }

    // MARK: - EntryInfo Default Document Properties

    func testEntryInfo_defaultDocumentProperties() {
        struct MockEntry: EntryInfo {
            let id: Int64 = 1
            let uri: String = "/test/entry"
            let name: String = "entry"
            let kind: String = "document"
            let isGroup: Bool = false
            let size: Int64 = 100
            let parentID: Int64 = 0
            let createdAt: Date = Date()
            let changedAt: Date = Date()
            let modifiedAt: Date = Date()
            let accessAt: Date = Date()

            func toGroup() -> EntryGroup? { nil }
        }

        let entry = MockEntry()

        XCTAssertNil(entry.documentTitle)
        XCTAssertNil(entry.documentAuthor)
        XCTAssertNil(entry.documentYear)
        XCTAssertNil(entry.documentSource)
        XCTAssertNil(entry.documentAbstract)
        XCTAssertNil(entry.documentKeywords)
        XCTAssertNil(entry.documentNotes)
        XCTAssertNil(entry.documentURL)
        XCTAssertNil(entry.documentHeaderImage)
        XCTAssertEqual(entry.documentMarked, false)
        XCTAssertEqual(entry.documentUnread, false)
        XCTAssertNil(entry.documentPublishAt)
        XCTAssertNil(entry.documentSiteName)
        XCTAssertNil(entry.documentSiteURL)
    }

    // MARK: - EntryDetail Default Document Properties

    func testEntryDetail_defaultDocumentProperties() {
        struct MockDetail: EntryDetail {
            let id: Int64 = 1
            let uri: String = "/test/detail"
            let name: String = "detail"
            let aliases: String? = nil
            let parent: Int64 = 0
            let kind: String = "document"
            let isGroup: Bool = false
            let size: Int64 = 100
            let version: Int64? = nil
            let namespace: String? = nil
            let storage: String? = nil
            let uid: Int64? = nil
            let gid: Int64? = nil
            let permissions: [String]? = nil
            let createdAt: Date = Date()
            let changedAt: Date = Date()
            let modifiedAt: Date = Date()
            let accessAt: Date = Date()
            let property: EntryPropertyInfo? = nil

            func toInfo() -> EntryInfo? { nil }
            func toGroup() -> EntryGroup? { nil }
        }

        let detail = MockDetail()

        XCTAssertNil(detail.documentTitle)
        XCTAssertNil(detail.documentAuthor)
        XCTAssertNil(detail.documentYear)
        XCTAssertEqual(detail.documentMarked, false)
        XCTAssertEqual(detail.documentUnread, false)
        XCTAssertEqual(detail.content, "")
    }
}
