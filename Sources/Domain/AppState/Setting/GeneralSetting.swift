//
//  GeneralSetting.swift
//  Domain
//
//  Created by Hypo on 2024/12/11.
//

import SwiftUI


public class GeneralSetting {
    @AppStorage("org.basenana.general.inboxFileType", store: UserDefaults.standard)
    public var inboxFileType: String = "webarchive"
    
    init () {}
}
