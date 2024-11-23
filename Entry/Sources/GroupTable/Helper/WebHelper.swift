//
//  WebHelper.swift
//  Entry
//
//  Created by Hypo on 2024/11/23.
//
import SwiftUI
import WebKit
import Foundation

func parseUrlString(urlStr: String) -> URL?{
    guard urlStr != "" else {
        return nil
    }
    return URL(string: urlStr)
}

func openUrlInBrowser(url: URL) {
    NSWorkspace.shared.open(url)
}
