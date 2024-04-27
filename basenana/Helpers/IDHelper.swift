//
//  IDHelper.swift
//  basenana
//
//  Created by Hypo on 2024/4/27.
//

import Foundation

struct IDHelper {
    var kind: String
    var id: Int64
    
    init(kind: String, id: Int64) {
        self.kind = kind
        self.id = id
    }
    
    init(encodedStr: String){
        let parts = encodedStr.components(separatedBy: ".")
        self.kind = parts[0]
        self.id = 0
        if parts.count > 1 {
            self.id = Int64(parts[1]) ?? 0
        }
    }
    
    func Encode() -> String {
        return "\(kind).\(id)"
    }
}

func parseIDInfo(entryInfos: [String]) -> [Int64] {
    var entryIDList: [Int64] = []
    for entryInfo in entryInfos {
        let idInfo = IDHelper(encodedStr: entryInfo)
        if idInfo.id > 0 {
            entryIDList.append(idInfo.id)
            continue
        }
        log.error("can not parse id info \(entryInfo)")
    }
    return entryIDList
}

