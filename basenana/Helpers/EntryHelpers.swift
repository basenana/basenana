//
//  EntryHelpers.swift
//  basenana
//
//  Created by Hypo on 2024/3/12.
//

import Foundation
import Frostflake


let entryIDGenerator = Frostflake(generatorIdentifier: 1)

func genEntryID() -> Int64 {
    return Int64(entryIDGenerator .generate())
}
