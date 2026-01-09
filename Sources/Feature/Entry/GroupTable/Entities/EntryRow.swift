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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(info.id)
    }
    
    static func == (lhs: EntryRow, rhs: EntryRow) -> Bool {
        return lhs.info.id == rhs.info.id
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

func sanitizeFileName(_ fileName: String) -> String {
    let illegalFileNameCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>")
    
    var sanitizedFileName = fileName.components(separatedBy: illegalFileNameCharacters).joined(separator: "_")
    
    sanitizedFileName = sanitizedFileName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if sanitizedFileName == "." || sanitizedFileName == ".." {
        return ""
    }
    
    return sanitizedFileName
}
