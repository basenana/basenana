//
//  Entry.swift
//  
//
//  Created by Hypo on 2024/9/13.
//

import Foundation

public protocol EntryInfo {
    var id: Int64 { get }
    var name: String { get }
    var kind: String { get }
    var isGroup: Bool { get }
    var size: Int64 { get }
    var parentID: Int64 { get }

    var createdAt: Date { get }
    var changedAt: Date { get }
    var modifiedAt: Date { get }
    var accessAt: Date { get }
    
    
    func toGroup() -> Group?
}

public protocol EntryDetail {
    var id: Int64 { get }
    var name: String { get }
    var aliases: String { get }
    var parent: Int64 { get }
    var kind: String { get }
    var isGroup: Bool { get }
    var size: Int64 { get }
    var version: Int64 { get }
    var namespace: String { get }
    var storage: String { get }
    
    var uid: Int64 { get }
    var gid: Int64 { get }
    var permissions: [String] { get }
    
    var createdAt: Date { get }
    var changedAt: Date { get }
    var modifiedAt: Date { get }
    var accessAt: Date { get }
    
    var properties: [EntryProperty] { get }
}


public func isVisitable(en: EntryInfo) -> Bool{
    return !en.name.starts(with: ".")
}

public func isVisitable(en: EntryDetail) -> Bool{
    return !en.name.starts(with: ".")
}


public protocol EntryProperty {
    var key: String { get }
    var value : String { get }
    var encoded: Bool { get }
}


public struct EntryCreate {
    
}

public struct EntryUpdate {
    
}

public struct ChangeParentOption{
    
}
