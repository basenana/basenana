//
//  EntryService.swift
//  basenana
//
//  Created by Hypo on 2024/3/7.
//

import Foundation
import SwiftData
import SwiftUI
import Frostflake


class EntryService: ObservableObject {
    
    let rootEntryID: Int64 = 1
    let inboxEntryID: Int64 = 1024
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func rootEntry() -> EntryModel {
        var rootEntry: EntryModel
        do {
            let data = try modelContext.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.id == rootEntryID}))
            
            if data.first == nil{
                rootEntry = initRootEntry()
                modelContext.insert(rootEntry)
                try modelContext.save()
            }else{
                rootEntry = data.first!
            }
        }catch{
            debugPrint("fetch root entry failed")
            return initRootEntry()
        }
        return  rootEntry
    }
    
    
    func inboxEntry() -> EntryModel {
        var inboxEntry: EntryModel
        do {
            let data = try modelContext.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.id == inboxEntryID}))
            
            if data.first == nil{
                inboxEntry = initInboxEntry()
                modelContext.insert(inboxEntry)
                try modelContext.save()
            }else{
                inboxEntry = data.first!
            }
        }catch{
            debugPrint("fetch inbox entry failed")
            return initInboxEntry()
        }
        return inboxEntry
    }
    
    func quickInbox(urlStr: String, fileType: String, isClusterFree:Bool) {
        let newEntry = EntryModel(id: genEntryID(), name: urlStr, parent: inboxEntryID)
        modelContext.insert(newEntry)
        do {
            try modelContext.save()
        } catch {
            debugPrint("insert entry to inbox failed")
        }
        return
    }
    
    func getEntry(entryID: Int64) -> EntryModel? {
        do {
            let data = try modelContext.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.id == entryID}))
            if data.first == nil{
                return nil
            }
            return  data.first!
        }catch{
            debugPrint("fetch entry \(entryID) failed")
            return nil
        }
    }
    
    func listChildren(parentEntryID: Int64) -> [EntryModel]{
        do {
            let rtn = try modelContext.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.parent == parentEntryID}))
            return rtn
        }catch{
            debugPrint("fetch entry \(parentEntryID) children failed")
            return []
        }
    }
    
    func genEntryID() -> Int64 {
        return Int64(Frostflake(generatorIdentifier: 1).generate())
    }
    
    func reflush() {
        self.objectWillChange.send()
    }
}

func initRootEntry() -> EntryModel {
    debugPrint("init root entry")
    return EntryModel(id: 1,name: "root", parent: 1, kind: "group")
}

func initInboxEntry() -> EntryModel {
    debugPrint("init inbox entry")
    return EntryModel(id: 1024,name: ".inbox", parent: 1, kind: "group")
}

