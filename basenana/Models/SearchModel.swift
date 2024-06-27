//
//  SearchModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/24.
//

import Foundation


class SearchModel {
    var query: String = ""
    
    func filterEntryName(_ en: EntryInfoModel) -> Bool{
        if query.isEmpty {
            return true
        }
        for part in query.lowercased().components(separatedBy: " "){
            if !en.name.lowercased().contains(part){
                return false
            }
        }
        return true
    }
}
