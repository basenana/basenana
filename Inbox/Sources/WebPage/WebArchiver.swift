//
//  WebArchiver.swift
//  Inbox
//
//  Created by Hypo on 2024/11/19.
//
import Foundation
import WebArchiver


func webarchiveBaseMainResource(url: URL, mainResource: String) -> Data?{
    var pData: Data?
    let group = DispatchGroup()
    group.enter()
    WebArchiver.archiveWithMainResource(url: url, htmlContent: mainResource){ result in
        pData = result.plistData
        group.leave()
    }
    group.wait()
    return pData
}

