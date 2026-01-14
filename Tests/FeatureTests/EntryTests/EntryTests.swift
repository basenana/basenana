import XCTest
@testable import Feature
@testable import Domain

final class EntryTests: XCTestCase {

    // MARK: - EntryFilter Tests

    func testEntryFilter_defaultValues() {
        let filter = EntryFilter(parentUri: "/test")

        XCTAssertEqual(filter.parentUri, "/test")
        XCTAssertNil(filter.kind)
        XCTAssertNil(filter.groupOnly)
        XCTAssertNil(filter.fileOnly)
        XCTAssertNil(filter.page)
        XCTAssertNil(filter.order)
        XCTAssertNil(filter.orderDesc)
    }

    func testEntryFilter_withPagination() {
        var filter = EntryFilter(parentUri: "/test")
        filter.page = Pagination()
        filter.page?.page = 1
        filter.page?.pageSize = 20

        XCTAssertNotNil(filter.page)
        XCTAssertEqual(filter.page?.page, 1)
        XCTAssertEqual(filter.page?.pageSize, 20)
    }

    func testEntryFilter_withKind() {
        var filter = EntryFilter(parentUri: "/test")
        filter.kind = "document"

        XCTAssertEqual(filter.kind, "document")
    }

    func testEntryFilter_withGroupOnly() {
        var filter = EntryFilter(parentUri: "/test")
        filter.groupOnly = true

        XCTAssertTrue(filter.groupOnly == true)
    }

    func testEntryFilter_withFileOnly() {
        var filter = EntryFilter(parentUri: "/test")
        filter.fileOnly = true

        XCTAssertTrue(filter.fileOnly == true)
    }

    func testEntryFilter_withOrder() {
        var filter = EntryFilter(parentUri: "/test")
        filter.order = .name
        filter.orderDesc = true

        XCTAssertEqual(filter.order, .name)
        XCTAssertTrue(filter.orderDesc == true)
    }

    func testEntryFilter_combinedOptions() {
        var filter = EntryFilter(parentUri: "/documents")
        filter.kind = "document"
        filter.groupOnly = false
        filter.fileOnly = true
        filter.page = Pagination()
        filter.page?.page = 2
        filter.page?.pageSize = 50
        filter.order = .modifiedAt
        filter.orderDesc = true

        XCTAssertEqual(filter.parentUri, "/documents")
        XCTAssertEqual(filter.kind, "document")
        XCTAssertFalse(filter.groupOnly == true)
        XCTAssertTrue(filter.fileOnly == true)
        XCTAssertEqual(filter.page?.page, 2)
        XCTAssertEqual(filter.order, .modifiedAt)
        XCTAssertTrue(filter.orderDesc == true)
    }

    // MARK: - DocumentFilter Tests

    func testDocumentFilter_defaultValues() {
        let filter = DocumentFilter()

        XCTAssertNil(filter.unread)
        XCTAssertNil(filter.marked)
        XCTAssertNil(filter.search)
        XCTAssertNil(filter.page)
        XCTAssertNil(filter.order)
        XCTAssertNil(filter.orderDesc)
    }

    func testDocumentFilter_unreadOnly() {
        var filter = DocumentFilter()
        filter.unread = true

        XCTAssertTrue(filter.unread == true)
    }

    func testDocumentFilter_markedOnly() {
        var filter = DocumentFilter()
        filter.marked = true

        XCTAssertTrue(filter.marked == true)
    }

    func testDocumentFilter_searchOnly() {
        var filter = DocumentFilter()
        filter.search = "swift"

        XCTAssertEqual(filter.search, "swift")
    }

    func testDocumentFilter_searchWithPagination() {
        var filter = DocumentFilter()
        filter.search = "test query"
        filter.page = Pagination()
        filter.page?.page = 1
        filter.page?.pageSize = 30

        XCTAssertEqual(filter.search, "test query")
        XCTAssertNotNil(filter.page)
        XCTAssertEqual(filter.page?.pageSize, 30)
    }

    func testDocumentFilter_unreadAndMarked() {
        var filter = DocumentFilter()
        filter.unread = true
        filter.marked = true

        XCTAssertTrue(filter.unread == true)
        XCTAssertTrue(filter.marked == true)
    }

    func testDocumentFilter_withOrderAndDesc() {
        var filter = DocumentFilter()
        filter.order = .createdAt
        filter.orderDesc = false

        XCTAssertEqual(filter.order, .createdAt)
        XCTAssertFalse(filter.orderDesc == true)
    }

    func testDocumentFilter_allOptionsCombined() {
        var filter = DocumentFilter()
        filter.unread = false
        filter.marked = true
        filter.search = "important"
        filter.page = Pagination()
        filter.page?.page = 3
        filter.page?.pageSize = 25
        filter.order = .name
        filter.orderDesc = true

        XCTAssertFalse(filter.unread == true)
        XCTAssertTrue(filter.marked == true)
        XCTAssertEqual(filter.search, "important")
        XCTAssertEqual(filter.page?.page, 3)
        XCTAssertEqual(filter.order, .name)
        XCTAssertTrue(filter.orderDesc == true)
    }

    // MARK: - EntryCreate Tests

    func testEntryCreate_minimalProperties() {
        let create = EntryCreate(
            parentUri: "/test",
            name: "newEntry",
            kind: "document"
        )

        XCTAssertEqual(create.parentUri, "/test")
        XCTAssertEqual(create.name, "newEntry")
        XCTAssertEqual(create.kind, "document")
        XCTAssertNil(create.RSS)
        XCTAssertNil(create.properties)
        XCTAssertNil(create.tags)
        XCTAssertNil(create.document)
    }

    func testEntryCreate_withAllProperties() {
        let rssConfig = RSSConfig(
            feed: "https://example.com/feed",
            siteName: "Example",
            siteURL: "https://example.com",
            fileType: .xml
        )

        let document = DocumentCreate(
            title: "Test Title",
            author: "Test Author",
            year: "2024",
            source: "Test Source",
            abstract: "Test Abstract",
            keywords: ["test", "swift"],
            notes: "Test Notes",
            url: "https://example.com/article",
            headerImage: "https://example.com/image.jpg"
        )

        let create = EntryCreate(
            parentUri: "/documents",
            name: "newDocument",
            kind: "document",
            RSS: rssConfig,
            properties: ["key1": "value1", "key2": "value2"],
            tags: ["important", "read"],
            document: document
        )

        XCTAssertEqual(create.parentUri, "/documents")
        XCTAssertEqual(create.name, "newDocument")
        XCTAssertEqual(create.kind, "document")
        XCTAssertNotNil(create.RSS)
        XCTAssertEqual(create.RSS?.feed, "https://example.com/feed")
        XCTAssertEqual(create.RSS?.siteName, "Example")
        XCTAssertEqual(create.properties?["key1"], "value1")
        XCTAssertEqual(create.tags?.count, 2)
        XCTAssertEqual(create.tags?.first, "important")
        XCTAssertNotNil(create.document)
        XCTAssertEqual(create.document?.title, "Test Title")
        XCTAssertEqual(create.document?.author, "Test Author")
        XCTAssertEqual(create.document?.year, "2024")
        XCTAssertEqual(create.document?.keywords?.count, 2)
    }

    func testEntryCreate_withEmptyPropertiesAndTags() {
        let create = EntryCreate(
            parentUri: "/test",
            name: "entry",
            kind: "document",
            properties: [:],
            tags: []
        )

        XCTAssertNotNil(create.properties)
        XCTAssertTrue(create.properties?.isEmpty == true)
        XCTAssertNotNil(create.tags)
        XCTAssertTrue(create.tags?.isEmpty == true)
    }

    // MARK: - DocumentCreate Tests

    func testDocumentCreate_defaultInit() {
        let document = DocumentCreate()

        XCTAssertNil(document.title)
        XCTAssertNil(document.author)
        XCTAssertNil(document.year)
        XCTAssertNil(document.source)
        XCTAssertNil(document.abstract)
        XCTAssertNil(document.keywords)
        XCTAssertNil(document.notes)
        XCTAssertNil(document.url)
        XCTAssertNil(document.headerImage)
    }

    func testDocumentCreate_withTitleOnly() {
        let document = DocumentCreate(title: "Only Title")

        XCTAssertEqual(document.title, "Only Title")
        XCTAssertNil(document.author)
    }

    func testDocumentCreate_withAllFields() {
        let document = DocumentCreate(
            title: "Full Document",
            author: "John Doe",
            year: "2024",
            source: "Journal of Testing",
            abstract: "This is the abstract",
            keywords: ["kw1", "kw2", "kw3"],
            notes: "Personal notes",
            url: "https://example.com/doc",
            headerImage: "https://example.com/header.jpg"
        )

        XCTAssertEqual(document.title, "Full Document")
        XCTAssertEqual(document.author, "John Doe")
        XCTAssertEqual(document.year, "2024")
        XCTAssertEqual(document.source, "Journal of Testing")
        XCTAssertEqual(document.abstract, "This is the abstract")
        XCTAssertEqual(document.keywords?.count, 3)
        XCTAssertEqual(document.notes, "Personal notes")
        XCTAssertEqual(document.url, "https://example.com/doc")
        XCTAssertEqual(document.headerImage, "https://example.com/header.jpg")
    }

    // MARK: - RSSConfig Tests

    func testRSSConfig_initializesCorrectly() {
        let rss = RSSConfig(
            feed: "https://example.com/rss",
            siteName: "Example Site",
            siteURL: "https://example.com",
            fileType: .xml
        )

        XCTAssertEqual(rss.feed, "https://example.com/rss")
        XCTAssertEqual(rss.siteName, "Example Site")
        XCTAssertEqual(rss.siteURL, "https://example.com")
        XCTAssertEqual(rss.fileType, .xml)
    }

    func testRSSConfig_differentFileTypes() {
        for fileType in [FileType.xml, .json, .markdown, .webarchive] {
            let rss = RSSConfig(
                feed: "https://test.com/feed",
                siteName: "Test",
                siteURL: "https://test.com",
                fileType: fileType
            )
            XCTAssertEqual(rss.fileType, fileType)
        }
    }

    func testFileType_option_returnsRawValue() {
        XCTAssertEqual(FileType.xml.rawValue, "xml")
        XCTAssertEqual(FileType.json.rawValue, "json")
        XCTAssertEqual(FileType.markdown.rawValue, "markdown")
        XCTAssertEqual(FileType.webarchive.rawValue, "webarchive")
    }

    func testFileType_initOption_validStrings() {
        XCTAssertEqual(FileType(option: "xml"), .xml)
        XCTAssertEqual(FileType(option: "json"), .json)
        XCTAssertEqual(FileType(option: "markdown"), .markdown)
        XCTAssertEqual(FileType(option: "webarchive"), .webarchive)
    }

    func testFileType_initOption_invalidString() {
        XCTAssertNil(FileType(option: "unknown"))
        XCTAssertNil(FileType(option: "txt"))
    }

    func testFileType_optionMethod() {
        XCTAssertEqual(FileType.xml.option(), "xml")
        XCTAssertEqual(FileType.json.option(), "json")
    }

    // MARK: - EntryUpdate Tests

    func testEntryUpdate_initializesCorrectly() {
        let update = EntryUpdate(id: 123, name: "New Name")

        XCTAssertEqual(update.id, 123)
        XCTAssertEqual(update.name, "New Name")
    }

    // MARK: - EntryPropertyInfo Tests

    func testEntryPropertyInfo_defaultInit() {
        let property = EntryPropertyInfo()

        XCTAssertNil(property.tags)
        XCTAssertNil(property.properties)
    }

    func testEntryPropertyInfo_withTagsAndProperties() {
        let property = EntryPropertyInfo(
            tags: ["tag1", "tag2"],
            properties: ["prop1": "val1"]
        )

        XCTAssertEqual(property.tags?.count, 2)
        XCTAssertEqual(property.properties?["prop1"], "val1")
    }

    // MARK: - ChangeParentOption Tests

    func testChangeParentOption_defaultValues() {
        let option = ChangeParentOption()

        XCTAssertEqual(option.newName, "")
    }

    // MARK: - EntryOrder Tests

    func testEntryOrder_allCases() {
        let cases: [EntryOrder] = [.name, .kind, .isGroup, .size, .createdAt, .modifiedAt]

        XCTAssertEqual(cases.count, 6)
        XCTAssertTrue(cases.contains(.name))
        XCTAssertTrue(cases.contains(.kind))
        XCTAssertTrue(cases.contains(.isGroup))
        XCTAssertTrue(cases.contains(.size))
        XCTAssertTrue(cases.contains(.createdAt))
        XCTAssertTrue(cases.contains(.modifiedAt))
    }
}
