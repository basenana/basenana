//
//  DB.swift
//  basenana
//
//  Created by Hypo on 2024/4/15.
//

import GRDB
import SwiftUI

let dbInstance = Database()

class Database {
    
    var queue: DatabaseQueue

    init(){
        print("opening db")
        let fileManager = FileManager.default
        let appSupportURL = try! fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true)
        let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
        try! fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        // Open or create the database
        let databaseURL = directoryURL.appendingPathComponent("basenana.sqlite")
        print("database path \(databaseURL.path)")
        self.queue = try! DatabaseQueue(path: databaseURL.path)
        
        let migrator = buildMigration()
        try! migrator.migrate(queue)
    }
    
    func buildMigration() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("Db init") { db in
            try migrateDbInit(db: db)
        }
        return migrator
    }
}

func migrateDbInit(db: GRDB.Database) throws {
    try db.create(table: "entry"){ t in
        t.column("id", .integer)
        t.column("name", .text)
        t.column("aliases", .text)
        t.column("parent", .integer)
        t.column("kind", .text)
        t.column("isGroup", .boolean)
        t.column("size", .integer)
        t.column("version", .integer)
        t.column("namespace", .text)
        t.column("storage", .text)
        
        t.column("uid", .integer)
        t.column("gid", .integer)
        t.column("permissions", .jsonText)
        
        t.column("createdAt", .datetime)
        t.column("changedAt", .datetime)
        t.column("modifiedAt", .datetime)
        t.column("accessAt", .datetime)
        t.column("syncAt", .datetime)

        t.primaryKey(["id"])
    }
    
    try db.create(table: "document"){ t in
        t.column("id", .integer)
        t.column("oid", .integer)
        t.column("name", .text)
        t.column("parentEntry", .integer)
        t.column("source", .text)
        t.column("marked", .boolean)
        t.column("unread", .boolean)

        t.column("keyWords", .jsonText)
        t.column("content", .text)
        t.column("summary", .text)
        
        t.column("createdAt", .datetime)
        t.column("changedAt", .datetime)
        t.column("syncAt", .datetime)

        t.primaryKey(["id"])
    }
    
    try db.create(table: "dialogue"){ t in
        t.column("id", .integer)
        t.column("oid", .integer)
        t.column("docid", .integer)
        t.column("messages", .jsonText)
        
        t.column("createdAt", .datetime)
        t.column("changedAt", .datetime)
        
        t.primaryKey(["id"])
    }
    
    try db.create(table: "config"){ t in
        t.column("id", .integer)
        t.column("name", .text)
        t.column("value", .text)
        t.column("changedAt", .datetime)
        
        t.primaryKey(["id"])
    }
}

