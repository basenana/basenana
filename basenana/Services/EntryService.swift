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
    
    @Environment(\.modelContext) private var context

    func rootEntry() -> EntryViewModel {
        var rootEntry: EntryModel
        do {
            let data = try context.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.id == rootEntryID}))
            
            if data.first == nil{
                rootEntry = initRootEntry()
                context.insert(rootEntry)
                try context.save()
            }else{
                rootEntry = data.first!
            }
        }catch{
            debugPrint("fetch root entry failed")
            return EntryViewModel(model: initRootEntry())
        }
        return EntryViewModel(model: rootEntry)
    }
    
    
    func inboxEntry() -> EntryViewModel {
        var inboxEntry: EntryModel
        do {
            let data = try context.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.id == inboxEntryID}))
            
            if data.first == nil{
                inboxEntry = initInboxEntry()
                context.insert(inboxEntry)
                try context.save()
            }else{
                inboxEntry = data.first!
            }
        }catch{
            debugPrint("fetch inbox entry failed")
            return EntryViewModel(model: initInboxEntry())
        }
        return EntryViewModel(model: inboxEntry)
    }
    
    func quickInbox(urlStr: String, fileType: String, isClusterFree:Bool) {
        let iEn = inboxEntry()
        var newEntry = EntryModel(id: genEntryID(), name: urlStr, parent: inboxEntryID)
        context.insert(newEntry)
        do {
            try context.save()
        } catch {
            debugPrint("insert entry to inbox failed")
        }
        return
    }
    
    func getEntry(entryID: Int64) -> EntryViewModel? {
        do {
            let data = try context.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.id == entryID}))
            if data.first == nil{
                return nil
            }
            return EntryViewModel(model: data.first!)
        }catch{
            debugPrint("fetch entry \(entryID) failed")
            return nil
        }
    }
    
    func listChildren(parentEntryID: Int64) -> [EntryViewModel]{
        do {
            let rtn = try context.fetch(FetchDescriptor<EntryModel>(predicate: #Predicate{$0.parent == parentEntryID})).map{
                EntryViewModel(model: $0)
            }
            return rtn
        }catch{
            debugPrint("fetch entry \(parentEntryID) children failed")
            return []
        }
    }
    
    func listRootGroupTree() -> [GroupTreeViewModel]{
        return []
    }
    
    func genEntryID() -> Int64 {
        return Int64(Frostflake(generatorIdentifier: 1).generate())
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

