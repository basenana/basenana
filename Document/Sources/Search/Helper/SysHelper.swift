//
//  SysHelper.swift
//  Entry
//
//  Created by Hypo on 2024/11/23.
//
import Foundation
import AppKit


func copyToClipBoard(content: String){
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.setString(content, forType: .string)
}
