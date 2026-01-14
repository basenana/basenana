import XCTest
@testable import Domain

final class DomainTests: XCTestCase {

    // MARK: - randomString Tests

    func testRandomString_lengthZero_returnsEmpty() {
        let result = randomString(randomOfLength: 0)
        XCTAssertEqual(result, "")
    }

    func testRandomString_normalLength_generatesExpectedLength() {
        let length = 16
        let result = randomString(randomOfLength: length)
        XCTAssertEqual(result.count, length)
    }

    func testRandomString_generatesOnlyValidCharacters() {
        let result = randomString(randomOfLength: 100)
        let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let resultCharacterSet = CharacterSet(charactersIn: result)
        XCTAssertTrue(resultCharacterSet.isSubset(of: validCharacters))
    }

    func testRandomString_differentCalls_returnDifferentValues() {
        let result1 = randomString(randomOfLength: 10)
        let result2 = randomString(randomOfLength: 10)
        XCTAssertNotEqual(result1, result2)
    }

    // MARK: - RFC3339Formatter Tests

    func testRFC3339Formatter_createsValidFormatter() {
        let formatter = RFC3339Formatter()
        XCTAssertNotNil(formatter)
        XCTAssertEqual(formatter.locale.identifier, "en_US_POSIX")
        XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd'T'HH:mm:ssZ")
    }

    func testRFC3339Formatter_formatsDateCorrectly() {
        let formatter = RFC3339Formatter()
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2024, month: 1, day: 15, hour: 10, minute: 30, second: 45)
        guard let date = calendar.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let result = formatter.string(from: date)
        XCTAssertTrue(result.hasPrefix("2024-01-15T10:30:45"), "Expected prefix, got: \(result)")
    }

    func testRFC3339Formatter_parsesFormattedDate() {
        let formatter = RFC3339Formatter()
        let dateString = "2024-01-15T10:30:45+0000"
        let result = formatter.date(from: dateString)

        XCTAssertNotNil(result, "Failed to parse date: \(dateString)")
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: result!)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 15)
    }

    // MARK: - entryTitleName Tests

    func testEntryTitleName_normalEntry_returnsUppercasedName() {
        let mockEntry = MockEntryInfo(
            id: 1,
            uri: "/test/entry",
            name: "testEntry",
            kind: "document",
            isGroup: false,
            size: 100,
            parentID: 0,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date()
        )

        let result = entryTitleName(en: mockEntry)
        XCTAssertEqual(result, "TESTENTRY")
    }

    func testEntryTitleName_hiddenEntry_returnsEmpty() {
        let mockEntry = MockEntryInfo(
            id: 1,
            uri: "/test/.hidden",
            name: ".hidden",
            kind: "document",
            isGroup: false,
            size: 100,
            parentID: 0,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date()
        )

        let result = entryTitleName(en: mockEntry)
        XCTAssertEqual(result, "")
    }

    // MARK: - isVisitable Tests (EntryInfo)

    func testIsVisitable_normalEntry_returnsTrue() {
        let mockEntry = MockEntryInfo(
            id: 1,
            uri: "/test/normal",
            name: "normal",
            kind: "document",
            isGroup: false,
            size: 100,
            parentID: 0,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date()
        )

        XCTAssertTrue(isVisitable(en: mockEntry))
    }

    func testIsVisitable_hiddenEntry_returnsFalse() {
        let mockEntry = MockEntryInfo(
            id: 1,
            uri: "/test/.hidden",
            name: ".hidden",
            kind: "document",
            isGroup: false,
            size: 100,
            parentID: 0,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date()
        )

        XCTAssertFalse(isVisitable(en: mockEntry))
    }

    func testIsVisitable_dotStartEntry_returnsFalse() {
        let mockEntry = MockEntryInfo(
            id: 1,
            uri: "/test/.config",
            name: ".config",
            kind: "document",
            isGroup: false,
            size: 100,
            parentID: 0,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date()
        )

        XCTAssertFalse(isVisitable(en: mockEntry))
    }

    // MARK: - isVisitable Tests (EntryDetail)

    func testIsVisitable_detail_normalEntry_returnsTrue() {
        let mockDetail = MockEntryDetail(
            id: 1,
            uri: "/test/normal",
            name: "normal",
            aliases: nil,
            parent: 0,
            kind: "document",
            isGroup: false,
            size: 100,
            version: nil,
            namespace: nil,
            storage: nil,
            uid: nil,
            gid: nil,
            permissions: nil,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date(),
            property: nil
        )

        XCTAssertTrue(isVisitable(en: mockDetail))
    }

    func testIsVisitable_detail_hiddenEntry_returnsFalse() {
        let mockDetail = MockEntryDetail(
            id: 1,
            uri: "/test/.hidden",
            name: ".hidden",
            aliases: nil,
            parent: 0,
            kind: "document",
            isGroup: false,
            size: 100,
            version: nil,
            namespace: nil,
            storage: nil,
            uid: nil,
            gid: nil,
            permissions: nil,
            createdAt: Date(),
            changedAt: Date(),
            modifiedAt: Date(),
            accessAt: Date(),
            property: nil
        )

        XCTAssertFalse(isVisitable(en: mockDetail))
    }

    // MARK: - BizError Tests

    func testBizError_notGroup_exists() {
        let error = BizError.notGroup
        XCTAssertNotNil(error)
    }

    func testBizError_isGroup_exists() {
        let error = BizError.isGroup
        XCTAssertNotNil(error)
    }

    func testBizError_invalidArg_withMessage() {
        let message = "test message"
        let error = BizError.invalidArg(message)
        if case .invalidArg(let msg) = error {
            XCTAssertEqual(msg, message)
        } else {
            XCTFail("Expected invalidArg error")
        }
    }

    func testBizError_openFileError_exists() {
        let error = BizError.openFileError
        XCTAssertNotNil(error)
    }

    func testBizError_notReadable_exists() {
        let error = BizError.notReadable
        XCTAssertNotNil(error)
    }

    // MARK: - RepositoryError Tests

    func testRepositoryError_unimplement_exists() {
        let error = RepositoryError.unimplement
        XCTAssertNotNil(error)
    }

    func testRepositoryError_notFound_exists() {
        let error = RepositoryError.notFound
        XCTAssertNotNil(error)
    }

    func testRepositoryError_canceled_exists() {
        let error = RepositoryError.canceled
        XCTAssertNotNil(error)
    }

    // MARK: - UseCaseError Tests

    func testUseCaseError_canceled_exists() {
        let error = UseCaseError.canceled
        XCTAssertNotNil(error)
    }

    func testUseCaseError_unimplement_exists() {
        let error = UseCaseError.unimplement
        XCTAssertNotNil(error)
    }

    // MARK: - BackgroundJob Tests

    func testBackgroundJob_idContainsDateAndRandom() {
        let job = BackgroundJob(name: "test", startAt: Date())

        XCTAssertTrue(job.id.contains("-"))
        let components = job.id.split(separator: "-")
        XCTAssertTrue(components.count >= 2)
    }

    func testBackgroundJob_idFormat_valid() {
        let job = BackgroundJob(name: "test", startAt: Date())

        let idPattern = #"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4}-[a-zA-Z0-9]{10}$"#
        let regex = try! NSRegularExpression(pattern: idPattern)
        let range = NSRange(job.id.startIndex..., in: job.id)
        XCTAssertTrue(regex.firstMatch(in: job.id, range: range) != nil, "ID format doesn't match expected pattern: \(job.id)")
    }

    func testBackgroundJob_nameAssignedCorrectly() {
        let job = BackgroundJob(name: "myJob", startAt: Date())
        XCTAssertEqual(job.name, "myJob")
    }

    func testBackgroundJob_startAtAssignedCorrectly() {
        let startDate = Date()
        let job = BackgroundJob(name: "test", startAt: startDate)
        XCTAssertEqual(job.startAt, startDate)
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

    func toGroup() -> EntryGroup? {
        nil
    }
}

private struct MockEntryDetail: EntryDetail {
    let id: Int64
    let uri: String
    let name: String
    let aliases: String?
    let parent: Int64
    let kind: String
    let isGroup: Bool
    let size: Int64
    let version: Int64?
    let namespace: String?
    let storage: String?
    let uid: Int64?
    let gid: Int64?
    let permissions: [String]?
    let createdAt: Date
    let changedAt: Date
    let modifiedAt: Date
    let accessAt: Date
    let property: EntryPropertyInfo?

    func toInfo() -> EntryInfo? {
        nil
    }

    func toGroup() -> EntryGroup? {
        nil
    }
}
