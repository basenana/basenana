//
//  DatabaseSetting.swift
//  Domain
//
//  Created by Hypo on 2024/11/20.
//

import SwiftUI

public class DatabaseSetting {
    @AppStorage("org.basenana.nanafs.url", store: UserDefaults.standard)
    public var apiURL: String = "http://localhost:7081"

    @AppStorage("org.basenana.nanafs.auth.bearerToken", store: UserDefaults.standard)
    public var apiBearerToken: String = ""

    init() { }
}
