//
//  EntryService.swift
//  basenana
//
//  Created by Hypo on 2024/3/7.
//

import Foundation
import SwiftData
import SwiftUI
import GRDB

let entryService = EntryService()

class EntryService {
    
    func quickInbox(urlStr: String, fileType: String, isClusterFree:Bool) {
        
    }
    
    func getEntry(entryID: Int64) -> EntryModel? {
        do {
            let data: EntryModel? = try dbInstance.queue.read{ db in
                try EntryModel.all().filter(Column("id") == entryID).fetchOne(db)
                
            }
            return data
        } catch {
            return nil
        }
    }
    
    func listChildren(parentEntryID: Int64) -> [EntryModel]{
        do {
            let data: [EntryModel] = try dbInstance.queue.read{ db in
                try EntryModel.all().filter(Column("parent") == parentEntryID).fetchAll(db)
                
            }
            return data
        } catch {
            return []
        }
    }
}

