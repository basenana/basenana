//
//  NamespaceService.swift
//  basenana
//
//  Created by zww on 2024/5/20.
//

import Foundation
import GRDB

let namespaceService = NamespaceService()

class NamespaceService {
    
    func getOrSaveLocalNamespace(ns: NamespaceModel) {
        var newNs = ns
        do {
            let crt: NamespaceModel? = try dbInstance.queue.read{ db in
                try NamespaceModel.all().filter(Column("name") == ns.name).fetchOne(db)
            }
            if let _ = crt {
                return
            }
            let _ = try dbInstance.queue.write{ db in
                try newNs.save(db)
            }
        } catch {
            log.error("[nsService] create local namespace failed \(error)")
        }
        log.debug("[nsService] created new local namespace \(newNs.name)")
    }
    
    func updateNamespace(ns: NamespaceModel) {
        var newNs = ns
        
        do {
            let _ = try dbInstance.queue.write{ db in
                try newNs.save(db)
            }
        } catch {
            log.error("[nsService] update local namespace failed \(error)")
        }
        log.debug("[nsService] update new local namespace \(newNs.name)")
    }
}
