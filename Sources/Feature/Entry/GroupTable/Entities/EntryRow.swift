//
//  EntryRow.swift
//  Entry
//
//  Created by Hypo on 2024/11/19.
//
import Foundation
import Domain


struct EntryRow: Hashable, Identifiable {
    var id: Int64
    var uri: String
    var name: String
    var kind: String
    var isGroup: Bool
    var size: Int64
    var parentID: Int64

    var createdAt: Date
    var changedAt: Date
    var modifiedAt: Date
    var accessAt: Date

    var info: EntryInfo

    init(info: EntryInfo){
        self.id = info.id
        self.uri = info.uri
        self.name = info.name
        self.kind = info.kind
        self.isGroup = info.isGroup
        self.size = info.size
        self.parentID = info.parentID
        self.createdAt = info.createdAt
        self.changedAt = info.changedAt
        self.modifiedAt = info.modifiedAt
        self.accessAt = info.accessAt
        self.info = info
    }

    init(from cached: CachedEntry) {
        self.id = cached.id
        self.uri = cached.uri
        self.name = cached.name
        self.kind = cached.kind
        self.isGroup = cached.isGroup
        self.size = cached.size
        self.parentID = cached.parentID
        self.createdAt = cached.createdAt
        self.changedAt = cached.changedAt
        self.modifiedAt = cached.modifiedAt
        self.accessAt = cached.accessAt
        self.info = CachedEntryInfo(cached: cached)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EntryRow, rhs: EntryRow) -> Bool {
        return lhs.id == rhs.id
    }

    var readableSize: String {
        get {
            let kilobyte: Int64 = 1024
            let megabyte = kilobyte * 1024
            let gigabyte = megabyte * 1024
            let terabyte = gigabyte * 1024

            let bytes = size
            if bytes < kilobyte {
                return "\(bytes) B"
            } else if bytes < megabyte {
                return String(format: "%.2f KB", Double(bytes) / Double(kilobyte))
            } else if bytes < gigabyte {
                return String(format: "%.2f MB", Double(bytes) / Double(megabyte))
            } else if bytes < terabyte {
                return String(format: "%.2f GB", Double(bytes) / Double(gigabyte))
            } else {
                return String(format: "%.2f TB", Double(bytes) / Double(terabyte))
            }
        }
    }
}


// MARK: - CachedEntryInfo (implements EntryInfo from CachedEntry)

private struct CachedEntryInfo: EntryInfo {
    let cached: CachedEntry

    var id: Int64 { cached.id }
    var uri: String { cached.uri }
    var name: String { cached.name }
    var kind: String { cached.kind }
    var isGroup: Bool { cached.isGroup }
    var size: Int64 { cached.size }
    var parentID: Int64 { cached.parentID }
    var createdAt: Date { cached.createdAt }
    var changedAt: Date { cached.changedAt }
    var modifiedAt: Date { cached.modifiedAt }
    var accessAt: Date { cached.accessAt }

    func toGroup() -> EntryGroup? { nil }
}
