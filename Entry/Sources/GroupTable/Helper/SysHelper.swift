//
//  SysHelper.swift
//  Entry
//
//  Created by Hypo on 2024/11/23.
//
import Foundation
import AppKit
import Entities


func copyToClipBoard(content: String){
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.setString(content, forType: .string)
}


func isInternalFile(_ en: EntryInfo) -> Bool {
    return en.name.hasPrefix(".")
}

func isInternalFile(_ grp: Entities.Group) -> Bool {
    return grp.groupName.hasPrefix(".")
}
